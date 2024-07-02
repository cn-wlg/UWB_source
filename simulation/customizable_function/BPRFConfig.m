%% legal
%% Data Length
datalength = 999;
PSDULength = ceil(datalength/8);

%% Custom configuration
mode = 'BPRF';
cfg = struct;
cfg.Mode = mode;
% SHR configuratio
cfg.PreambleDuration = 64;
cfg.CodeIndex = 9;
cfg.SFDNumber = 0;
% STS configuration
cfg.STSPacketConfiguration = 1;
cfg.NumSTSSegments = 1;
cfg.STSSegmentLength = 64;
cfg.ExtraSTSGapLength = 0;
% PHR and Payload configuration
cfg.PSDULength = PSDULength;
cfg.ConstraintLength = 3;
% pulse configuration
cfg.SamplesPerPulse = 4;

%% Basic configuration
cfg.Channel = 0;
cfg.MeanPRF = 249.6; %% [3.9, 15.6, 62.4, 124.8, 249.6]
cfg.DataRate = 0.85; %% [0.11, 0.85, 1.7, 6.81, 27.24]
cfg.PHRDataRate = 0.85; %% [0.85, 6.81]
cfg.ExtraSTSGapIndex = 0;
cfg.PreambleMeanPRF = 16.1;
cfg.Ranging = false;
cfg.SampleRate = 1.9968e+09;

cfg.MeanPRFNum = getMeanPRFNum(cfg);
cfg.DataRateNum = getDataRateNum(cfg);
cfg.PeakPRF = getPeakPRF(cfg);
cfg.PreambleCodeLength = getPreambleCodeLength(cfg);
cfg.BurstsPerSymbol = getBurstsPerSymbol(cfg);
cfg.NumHopBursts = getNumHopBursts(cfg);
cfg.ChipsPerBurst = getChipsPerBurst(cfg);
cfg.ChipsPerSymbol = getChipsPerSymbol(cfg);
cfg.ConvolutionalCoding = getConvolutionalCoding(cfg);
cfg.PreambleSpreadingFactor = getPreambleSpreadingFactor(cfg);

%% Attacker
%% Attack SHR and STS cofiguration
cfg_ATK = struct;
cfg_ATK.Mode = mode;
% SHR configuratio
cfg_ATK.PreambleDuration = 64;
cfg_ATK.CodeIndex = 10;
cfg_ATK.SFDNumber = 0;
% STS configuration
cfg_ATK.STSPacketConfiguration = 1;
cfg_ATK.NumSTSSegments = 1;
cfg_ATK.STSSegmentLength = 64;
cfg_ATK.ExtraSTSGapLength = 0;
% PHR and Payload configuration
cfg_ATK.PSDULength = PSDULength;
cfg_ATK.ConstraintLength = 3;
% pulse configuration
cfg_ATK.SamplesPerPulse = 4;

%% Basic configuration
cfg_ATK.Channel = 0;
cfg_ATK.MeanPRF = 249.6; %% [3.9, 15.6, 62.4, 124.8, 249.6]
cfg_ATK.DataRate = 0.85; %% [0.11, 0.85, 1.7, 6.81, 27.24]
cfg_ATK.PHRDataRate = 0.85; %% [0.85, 6.81]
cfg_ATK.ExtraSTSGapIndex = 0;
cfg_ATK.PreambleMeanPRF = 16.1;
cfg_ATK.Ranging = false;
cfg_ATK.SampleRate = 1.9968e+09;

cfg_ATK.MeanPRFNum = getMeanPRFNum(cfg_ATK);
cfg_ATK.DataRateNum = getDataRateNum(cfg_ATK);
cfg_ATK.PeakPRF = getPeakPRF(cfg_ATK);
cfg_ATK.PreambleCodeLength = getPreambleCodeLength(cfg_ATK);
cfg_ATK.BurstsPerSymbol = getBurstsPerSymbol(cfg_ATK);
cfg_ATK.NumHopBursts = getNumHopBursts(cfg_ATK);
cfg_ATK.ChipsPerBurst = getChipsPerBurst(cfg_ATK);
cfg_ATK.ChipsPerSymbol = getChipsPerSymbol(cfg_ATK);
cfg_ATK.ConvolutionalCoding = getConvolutionalCoding(cfg_ATK);
cfg_ATK.PreambleSpreadingFactor = getPreambleSpreadingFactor(cfg_ATK);

save('BPRFConfigresult.mat','cfg','cfg_ATK');

%% functions
function prfNum = getMeanPRFNum(obj)
  if strcmp(obj.Mode, 'BPRF')
    prfNum = 62.4;
  else
    prfNum = obj.MeanPRF;
  end
end

function r = getDataRateNum(obj)
  if strcmp(obj.Mode, 'BPRF')
    r = 6810;
  else
    r = obj.DataRate*1e3; % handle with kbps internally
  end
end

function peak = getPeakPRF(obj)
  peak = 499.2;
  if strcmp(obj.Mode, 'HPRF') && obj.MeanPRFNum == 124.8
    peak = peak/2;
  end
end

function len = getPreambleCodeLength(obj)
  if obj.CodeIndex <= 8
    len = 31;
  elseif obj.CodeIndex <= 24
    len = 127;
  else % 25-32
    len = 91;
  end
end

function bps = getBurstsPerSymbol(obj)
  switch obj.MeanPRFNum
    case 15.6
      bps = 32;
    case 3.9
      bps = 128;
    otherwise % 62.4MHz
      bps = 8;
  end
end

function n = getNumHopBursts(obj)
  n = obj.BurstsPerSymbol/4;
end

function cpb = getChipsPerBurst(obj)
  switch obj.MeanPRFNum
    case 15.6
      if obj.DataRateNum == 110
        cpb = 128;
      elseif obj.DataRateNum == 850
        cpb = 16;
      elseif obj.DataRateNum == 6810
        cpb = [16 2];
      else % 27240
        cpb = [16 1];
      end
      
    case 3.9
      if obj.DataRateNum == 110
        cpb = 32;
      elseif obj.DataRateNum == 850
        cpb = 4;
      elseif obj.DataRateNum == 1700
        cpb = [4 2];
      else % 6810
        cpb = [4 1];
      end
      
    otherwise % 62.4MHz
      if obj.DataRateNum == 110
        cpb = 512;
      elseif obj.DataRateNum == 850
        cpb = 64;
      elseif obj.DataRateNum == 6810
        if obj.PHRDataRate == 0.85
          cpb = [64 8];
        else
          cpb = 8;
        end
      else % 27240
        cpb = [64 2];
      end
  end
end

function cps = getChipsPerSymbol(obj)
  if strcmp(obj.Mode, 'HPRF')
    if obj.ConstraintLength == 3
      % different modulation for PHR and payload
      cps = [16 8]*249.6/obj.MeanPRFNum; % [8 16] for 249.6, [16 32] for 124.8
    else
      % same pattern for PHR and payload
      cps = 8*249.6/obj.MeanPRFNum; % 8 for 249.6, 16 for 124.8
    end
  else % BPM-BPSK
    cps = obj.ChipsPerBurst*obj.BurstsPerSymbol;
  end
end

function b = getConvolutionalCoding(obj)
  % No coding for some cases, as per Table 15-3
  b = ~((obj.MeanPRFNum == 3.9  && obj.DataRateNum == 6810) || ...
        (obj.MeanPRFNum == 15.6 && obj.DataRateNum == 27240));
end

function L = getPreambleSpreadingFactor(obj)
  if obj.PreambleCodeLength > 31 % 127 or 91
    L = 4;
  else % 31
    if obj.PreambleMeanPRF == 16.1
      L = 16;
    else % 4.03
      L = 64;
    end
  end
end
