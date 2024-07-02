function [STS, STSbit] = createSTS(cfg,mode)
% As per Sec. 15.2.9 in IEEE Std 802.15.4z??\2020

STSbit = [];
len512 = 512; % chips
if(mode == 0)
gap = zeros(len512, 1);
else
gap = [];
end
STS = gap; % all STS start with a gap

if strcmp(cfg.Mode, 'HPRF') && cfg.STSPacketConfiguration == 2
  % add extra gap
  STS = [STS; zeros(4*cfg.ExtraSTSGapLength, 1)];
end

if strcmp(cfg.Mode, 'BPRF') % BPRF
  numSegments = 1;
  segLen = cfg.STSSegmentLength*512; % STSSegmentLength is in units of 512 chips
  spreadingF = 4;
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
s = load('legalDRBG.mat');
allDRBG = s.legalDRBG(:,:);
counter = 1;

for idx = 1:numSegments
  activeSTS = zeros(segLen, 1);
  
  numDBRG = (segLen/(singleDRBGlen*spreadingF));
  for idx2 = 1:numDBRG
    tmp = allDRBG(counter, :);
    singleDRBG = tmp(:);
    
    % Change 0s to +1 and 1 to -1:
    singleDRBG(singleDRBG==1) = -1;
    singleDRBG(singleDRBG==0) = +1;
    
    % Spread by spreadingFactor (4 or 8):    
    STSbit = [STSbit;singleDRBG];
    spreadBits = [singleDRBG'; zeros(spreadingF-1, singleDRBGlen)];
    spreadBits = spreadBits(:);

    activeSTS(1+(idx2-1)*singleDRBGlen*spreadingF : idx2*singleDRBGlen*spreadingF) = spreadBits;

    counter = counter+1;
  end
  STS = [STS; activeSTS; gap]; %#ok<AGROW>
end
end