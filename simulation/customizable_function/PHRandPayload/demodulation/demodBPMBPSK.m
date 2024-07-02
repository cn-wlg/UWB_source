function [cw, fieldEnd] = demodBPMBPSK(phrNotPayload, ternarySymbols, fieldStart, cfg, varargin)
  numPHRSym = 21;
  if phrNotPayload
    numSymbols = numPHRSym;
  else
    PSDULength = varargin{1};
    numSymbols = PSDULength;
  end
  cw = zeros(2, numSymbols);

  fieldEnd = fieldStart;
  
  if phrNotPayload
    offset = 0;
    pnSamplesPerFrame = cfg.ChipsPerBurst(1);
    chipsPerSymbol = cfg.ChipsPerSymbol(1);
  else
    offset = numPHRSym*cfg.ChipsPerBurst(1);
    pnSamplesPerFrame = cfg.ChipsPerBurst(end);
    chipsPerSymbol = cfg.ChipsPerSymbol(end);
  end

  load allPNSamples.mat
  symbols = reshape(ternarySymbols(fieldStart:fieldStart+numSymbols*chipsPerSymbol-1), chipsPerSymbol, []);
  for sym = 1:numSymbols
    thisSym = symbols(:, sym);
    % Find the burst with the highest energy, to find the used position:
    bursts = reshape(thisSym, pnSamplesPerFrame, []);
    burstPowers = sum(abs(bursts));
    [~, burstPosition] = max(burstPowers);
    
    % Systematic bit (g_0)
    systematicBit = burstPosition>cfg.BurstsPerSymbol/2;
    
    % Parity bit (g_1)
    thisBurst = bursts(:, burstPosition);

    % The Burst sequence is spreaded with the PN sequence and the Parity bit
    spreadingSeq  = allPNSamples(offset+1+(sym-1)*pnSamplesPerFrame: offset+sym*pnSamplesPerFrame, 1);
    seqFor0 = thisBurst./(1-2*spreadingSeq);
    seqFor1 = -seqFor0;
    % Find the most likely parity bit value given the received burst and
    % the current spreader sequence. Minimize bit differences (Hamming
    % distance), with hard decision:
    if sum(seqFor1) > sum(seqFor0)
      parityBit = 1;
    else
      parityBit = 0;
    end

    cw(:, sym) = [systematicBit; parityBit];
  end
  fieldEnd = fieldEnd + numSymbols*chipsPerSymbol-1;
end