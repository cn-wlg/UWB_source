function symbols = symbolMapper(convolCW, cfg)
% As per Sec. 15.3 in IEEE Std 802.15.4™‐2020

persistent pn % Persistent comm.PNSequence, as one-time setup is the computational bottleneck

% 0. Repackage input with 1 codeword per row
tmp = reshape(convolCW, 2, []);
cws = tmp';
numSym = size(cws, 1);
inHPRF = strcmp(cfg.Mode, 'HPRF');

phrLen = 19;
if ~inHPRF || cfg.ConstraintLength == 3
  numPHRsym = phrLen+2;
else % CL = 7 
  numPHRsym = phrLen+6;
end

% 2. Create spreading sequence obj
code = HRPCodes(cfg.CodeIndex);
codeHat = code;
% a. Remove all zeros
codeHat(codeHat==0) = [];
% b. Replace all -1 with zeros
codeHat(codeHat==-1) = 0;
% c. Keep the 1st 15
codeHat = codeHat(1:15);
initialConditions = fliplr(codeHat); % fliplr because of the difference in convention

% do a single PN sequence call, to facilitate codegen (pass InitialConditions and SamplesPerFrame as inputs)
if ~inHPRF
  numChips = cfg.ChipsPerBurst;
else
  numChips = cfg.ChipsPerSymbol;
end
totalSamples = numPHRsym*numChips(1) + (numSym-numPHRsym)*numChips(end);
% The maximum value of totalSamples under all configurations is about 600K.
maxSamples = 6.1e5;

% A different notation is used between standard and comm.PNSequence. The
% standard has the extra connection (D^14) close to the register that is
% wrapped around, which is D^1 for comm.PNSequence
load allPNSamples.mat

% 3. Modulate each codeword/symbol
% 3a. The first 21 symbols (PHR) is modulated at most at 850 kb/s = at least 16 chips per burst
% 3b. The rest (numSym-21) are modulated with cfgObj.DataRate
samplesPerBurst = nan; % init in all code paths, for codegen
if ~inHPRF
  samplesPerBurst = cfg.ChipsPerBurst;
  sps = cfg.BurstsPerSymbol*samplesPerBurst;
else
  sps = cfg.ChipsPerSymbol*2*249.6/cfg.MeanPRFNum;
end
% sps is a 1 or 2-element vector. If 2-element, 1st value is for PHR, 2nd is for PSDU
PHRorPSDU = 1;
PHR_ID = 1;
PSDU_ID = length(sps);
symbols = zeros(numPHRsym*sps(PHR_ID)+(numSym-numPHRsym)*sps(PSDU_ID), 1);

for symIdx = 1:numSym
  % Transition from PHR to PSDU. If rates are different, then PN sequence
  % needs different parameterization
  if ((inHPRF && cfg.ConstraintLength == 3) || (~inHPRF && ~isscalar(cfg.ChipsPerBurst))) && symIdx == numPHRsym+1
    PHRorPSDU = 1+double(symIdx>numPHRsym);
  end
  
  % Get each codeword one by one and construct each symbol one by one
  if PHRorPSDU == 1
    offset = 0;
    currSym = symIdx;
  else
    offset = numPHRsym*numChips(1);
    currSym = symIdx-numPHRsym;
  end
  spreadingSeq = allPNSamples(offset+1+(currSym-1)*numChips(PHRorPSDU): offset+currSym*numChips(PHRorPSDU), 1);
  systematicBit = cws(symIdx, 1);
  parityBit     = cws(symIdx, 2);
  
  thisSymbol = zeros(sps(PHRorPSDU), 1);

  if ~inHPRF
    % 3. Calculate burst hopping position
    m = log2(cfg.NumHopBursts);
    % Standard says that LFSR is not clocked more than ChipsPerBurst times, when m > Ncpb:
    m = min(m, cfg.ChipsPerBurst(PHRorPSDU));  % even though it doesn't say explicitly to limit m in h(k) calc
    burstPos = (2.^(0:m-1))*spreadingSeq(1:m);

    % 4. Create burst
    thisBurst = (1-2*parityBit)*(1-2*spreadingSeq');
    thisBurst = thisBurst(:);

    % 5. Place burst in the corresponding position
    burstNo = burstPos(1) + systematicBit*cfg.BurstsPerSymbol/2; % 0-based index; also, burstPos is scalar, but (1) helps codegen
    thisSymbol(1+burstNo*samplesPerBurst(PHRorPSDU):(burstNo+1)*samplesPerBurst(PHRorPSDU)) = thisBurst;
    
  else % HPRF
    len = 4*249.6/cfg.MeanPRFNum;
    symbolMap = hrpHPRFSymbolMap(cfg.MeanPRFNum, cfg.ConstraintLength);
    
    if PHRorPSDU == 1 % PHR
      numBits = size(symbolMap, 2);
    else % PSDU
      numBits = 2*len;
    end
    
    thisMapping = symbolMap(1+bit2int([systematicBit parityBit]', 2, false), 1:numBits);
    scrambled = (1-2*thisMapping) .* (1-2*spreadingSeq');
    
    % add guardbands:
    scrambled = [reshape(scrambled, len, []); ...
                 zeros(len, numBits/len)];
    scrambled = scrambled(:);
    
    if cfg.MeanPRFNum == 124.8
        % add a zero every other element
        scrambled = [scrambled'; 
                     zeros(1, numBits*2)];
        scrambled = scrambled(:);
    end
    thisSymbol = scrambled';
    thisSymbol = thisSymbol(:);
  end
  if PHRorPSDU == 1 % PHR
    startSymbolPos = 1+(symIdx-1)*sps(PHR_ID);
  else % PSDU
    phrEnd = numPHRsym*sps(PHR_ID);
    startSymbolPos = phrEnd + 1 +(symIdx-1-numPHRsym)*sps(PSDU_ID);
  end
  endSymbolPos = startSymbolPos + sps(PHRorPSDU)-1;
  symbols(startSymbolPos:endSymbolPos) = thisSymbol;
end