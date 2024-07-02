function [cw, fieldEnd] = demodHPRF(phrNotPayload, ternarySymbols, fieldStart, cfg, varargin)
  
  phrLen = 19;
  if cfg.MeanPRFNum < 124.8 || cfg.ConstraintLength == 3
    numPHRSym = phrLen+2;
  else % CL = 7 
    numPHRSym = phrLen+6;
  end
  if phrNotPayload
    numSymbols = numPHRSym;
  else
    PSDULength = varargin{1};
    numSymbols = PSDULength;
  end
  cw = zeros(2, numSymbols); % pre-allocate to prevent auto-grow in FOR loop

  fieldEnd = fieldStart; % init
  
  if cfg.MeanPRFNum > 124.8
    chipsPerSymbol = 16 * (1+phrNotPayload); % double the symbols for PHR
  else
    chipsPerSymbol = 64 * (1+phrNotPayload);
  end
  if cfg.ConstraintLength==7 && phrNotPayload
    chipsPerSymbol = chipsPerSymbol/2;
  end
  % chipsPerSymbol above includes guard bands. ChipsPerSymbol from
  % lrwpanHRPConfig describes only the meaningful content (without guard bands)
  if phrNotPayload
    pnSamplesPerFrame = cfg.ChipsPerSymbol(1);
    pnMaskOffset = 0;
  else
    pnSamplesPerFrame = cfg.ChipsPerSymbol(end);
    pnMaskOffset = numPHRSym*cfg.ChipsPerSymbol(1);
  end
  pn = createScrambler(cfg.CodeIndex, pnSamplesPerFrame, pnMaskOffset);
    
  symbols = reshape(ternarySymbols(fieldStart:fieldStart+numSymbols*chipsPerSymbol-1), chipsPerSymbol, []);
  if cfg.MeanPRFNum == 124.8
    symbols = symbols(1:2:end, :); % extra guard band between chips for 124.8 MHz
  end
  
  % Demodulate, ChipsPerSymbol bits -> 2-bit codewords
  symbolMap = hrpHPRFSymbolMap(cfg.MeanPRFNum, cfg.ConstraintLength);
  if ~phrNotPayload && cfg.ConstraintLength==3
    symbolMap = symbolMap(:, 1:(end*(1+phrNotPayload)/2));
  end
  longerPHR = phrNotPayload && (cfg.ConstraintLength==3);
  for sym = 1:numSymbols
    thisSym = symbols(:, sym);
    
    % remove guard bands:
    thisSym = reshape(thisSym, [], 4*(1+longerPHR));
    thisSym = thisSym(:, 1:2:end);
    thisSym = thisSym(:);
    
    % Despread/Descramble:
    spreadingSeq  = pn();
    thisSym = thisSym./(1-2*spreadingSeq);
    
    % Bipolar to unipolar conversion: -1->1, 1->0
    thisSym = (1-thisSym)/2;
    
    % project the current symbol to all possible symbols. Choose
    % (demodulate) the one with the smallest Hamming distance (bit errors)
    [~, demodIdx] = min(sum(xor(symbolMap, thisSym'), 2));
    
    % Map table index to binary codeword from Tables 15-10c/d/ef
    msbFirst = false;
    cw(:, sym) = int2bit(demodIdx-1, 2, msbFirst);
  end
  
  fieldEnd = fieldEnd + chipsPerSymbol*numSymbols -1;
end