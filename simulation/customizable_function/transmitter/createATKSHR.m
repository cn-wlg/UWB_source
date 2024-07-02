function [SHR, SYNC, SFD] = createATKSHR(cfg)

% SYNC
% As per Sec. 15.2.6.2 in IEEE Std 802.15.4?�\2020
code = lrwpan.internal.HRPCodes(cfg.CodeIndex);
ATKcode = round(rand(size(code))*2-1);
L = cfg.PreambleSpreadingFactor;
N = cfg.PreambleDuration;

% 1. Add L-1 zeros after each ternary (-1, 0, +1) symbol of the code
spread = zeros(L*length(ATKcode), 1);
spread(1:L:end) = ATKcode;

% 2. Repeat spread sequence N times (spread seq is also referred as a symbol)
SYNC = repmat(spread, N, 1);


% SFD (Start of Frame delimiter)
% As per Sec. 15.2.6.3 in IEEE Std 802.15.4?�\2020
seq = lrwpan.internal.getSFD(cfg);
ATKseq =  round(rand(size(seq))*2-1);
SFD = ATKseq.*spread;
SFD = SFD(:);

SHR = [SYNC; SFD];
end

% STS (Srambled Timestamp Sequence)
function STS = createSTS(cfg)
% As per Sec. 15.2.9 in IEEE Std 802.15.4z?�\2020

len512 = 512; % chips
gap = zeros(len512, 1);
STS = gap; % all STS start with a gap

if strcmp(cfg.Mode, 'HPRF') && cfg.STSPacketConfiguration == 2
  % add extra gap
  STS = [STS; zeros(4*cfg.ExtraSTSGapLength, 1)];
end

if strcmp(cfg.Mode, 'BPRF') % BPRF
  numSegments = 1;
  segLen = 64*512; % STSSegmentLength is in units of 512 chips
  spreadingF = 8;
else % HPRF
  numSegments = cfg.NumSTSSegments;
  segLen = cfg.STSSegmentLength*512; % STSSegmentLength is in units of 512 chips
  spreadingF = 4;
end

singleDRBGlen = 128;

% Get DRBG bits already prepared for:
% key='4a5572bc90798c8e518d2449092f1b55',
% upper96 = '68debd3a599939dd57fdbb0e'
% lower32 = '2a10fac0'
% They are packed as uint8, so convert to bits:
s = coder.load('allDRBG_STS.mat');
allDRBG = s.allDRBG;

counter = 1;

for idx = 1:numSegments
  activeSTS = zeros(segLen, 1);
  
  numDBRG = (segLen/(singleDRBGlen*spreadingF));
  for idx2 = 1:numDBRG
    
    singleDRBG_uint8 = allDRBG(counter, :);
    tmp = int2bit(singleDRBG_uint8, 8);
    singleDRBG = double(tmp(:));
    
    % Change 0s to +1 and 1 to -1:
    singleDRBG(singleDRBG==1) = -1;
    singleDRBG(singleDRBG==0) = +1;
    
    % Spread by spreadingFactor (4 or 8):    
    spreadBits = [singleDRBG'; zeros(spreadingF-1, singleDRBGlen)];
    spreadBits = spreadBits(:);
    
    activeSTS(1+(idx2-1)*singleDRBGlen*spreadingF : idx2*singleDRBGlen*spreadingF) = spreadBits;

    counter = counter+1;
  end
  STS = [STS; activeSTS; gap]; %#ok<AGROW>
end
end