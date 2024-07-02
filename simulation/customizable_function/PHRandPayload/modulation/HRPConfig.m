classdef HRPConfig < comm.internal.ConfigBase
%LRWPANHRPCONFIG Configuration object for HRP PHY of IEEE 802.15.4a/z
%   CFG = lrwpanHRPConfig creates a configuration object for an HRP IEEE
%   802.15.4a/z UWB waveform. This object parameterizes HPRF and BPRF modes
%   as well as the traditional IEEE 802.15.4a operation.
%
%   CFG = lrwpanHRPConfig(Name,Value) creates an HRP IEEE 802.15.4a/z
%   waveform configuration object with the specified property Name set to
%   the specified Value. You can specify additional name-value pair
%   arguments in any order as (Name1,Value1,...,NameN,ValueN).
%
%   lrwpanHRPConfig properties:
%
%   Channel                 - Channel number
%   Mode                    - Operation mode
%   MeanPRF                 - Mean pulse repetition frequency (in MHz)
%   DataRate                - Payload data rate (in Mbps)
%   PHRDataRate             - PHR data rate (in Mbps)
%   SamplesPerPulse         - Number of samples per Butterworth pulse
%   STSPacketConfiguration  - Control STS placement within the packet
%   NumSTSSegments          - Number of STS segments
%   STSSegmentLength        - Length of active STS segments as a multiple of 512 chips
%   ExtraSTSGapLength       - Length of extra STS gap, as a multiple of 4 chips
%   ExtraSTSGapIndex        - Index of extra STS gap value
%   CodeIndex               - Index of used SYNC code from Tables 15-6, 15-7 and 15-7a
%   PreambleMeanPRF         - Mean PRF (pulse repetition frequency) of the preamble (in MHz)
%   PreambleDuration        - Number of repetitions of spread preamble SYNC codes
%   SFDNumber               - Index of Start-of-Frame Delimiter choice
%   Ranging                 - Flag denoting if the PHY frame is for ranging
%   ConstraintLength        - Flag denoting the constraint length of convolutional coding
%   PSDULength              - Length of PHY service data unit (in bytes)
%   SampleRate              - Sample rate of waveform
%
%   Properties returned by info() method:
%
%   PeakPRF                 - Peak pulse repetition frequency
%   BurstsPerSymbol         - Number of bursts per symbol (see Table 15-3)
%   NumHopBursts            - Number of candidate bursts per symbol (see Table 15-3)
%   ChipsPerBurst           - Number of chips per burst (see Table 15-3)
%   ChipsPerSymbol          - Number of chips per symbol (see Table 15-3)
%   ConvolutionalCoding     - Flag for activation of the payload convolutional encoder
%   PreambleCodeLength      - Length of preamble in symbols
%   PreambleSpreadingFactor - Length of delta function spreading code
%
%   lrwpanHRPConfig methods:
%
%   info - Return information such as sample rate and modulation characteristics
%
%   When the STS field is enabled (i.e., when Mode is 'HPRF' or 'BPRF' and
%   STSPacketConfiguration is greater than 0), it is created with:
%      STS key = "4a5572bc90798c8e518d2449092f1b55", and
%      STS counter ([upper96 lower32]) = ["68debd3a599939dd57fdbb0e" "2a10fac0"].
%   These values are widely used in test vectors released by IEEE.
%
%   Example 1:
%     % Create an HPRF IEEE 802.15.4z waveform.
%     psdu = randi([0, 1], 8*200, 1);
%     cfgHPRF = lrwpanHRPConfig(Mode='HPRF', ...    % HPRF mode
%                  MeanPRF=124.8, ...               % 16 chips per payload symbol
%                  Channel=3, ...                   % Mandatory low-band channel
%                  CodeIndex=27, ...                % One of the 91-symbols long SYNC codes
%                  PreambleDuration=32, ...         % Number of repetitions for spread SYNC code
%                  SFDNumber=1, ...                 % Choose a 4-symbol long SFD
%                  STSPacketConfiguration=1, ...    % Enable STS before payload
%                  NumSTSSegments=2, ...            % 2 STS segments
%                  STSSegmentLength=32, ...         % Each segment is 32*512=16384 chips long
%                  ConstraintLength=7, ...          % Optional convolutional encoder, no RS coding for payload
%                  PSDULength=100);                 % PSDULength can be equal, greater or smaller than bit-input length
%     waveHPRF = lrwpanWaveformGenerator(psdu, cfgHPRF);
%     sa = spectrumAnalyzer(SampleRate=cfgHPRF.SampleRate);
%     sa(waveHPRF);
%
%   Example 2:
%     % Create a multi-frame BPRF IEEE 802.15.4z waveform.
%     psdu = randi([0, 1], 8*100, 1);
%     cfgBPRF = lrwpanHRPConfig(Mode='BPRF', ...
%                  STSPacketConfiguration=0, ...    % Turn off STS
%                  PHRDataRate=6.81, ...            % PHR at 6.81Mbps (BPRF payload always at 6.81 Mbps)
%                  CodeIndex=9, ...                 % One of the 127-symbols long SYNC codes
%                  PSDULength=length(psdu)/8);      % Each packet will loop around the bit input
%     waveBPRF = lrwpanWaveformGenerator(psdu, cfgBPRF, NumPackets=3, IdleTime=1e-4);
%     ts = timescope(SampleRate=cfgBPRF.SampleRate, TimeSpanSource="property", ...
%                 TimeSpan=length(waveBPRF)/cfgBPRF.SampleRate, YLimits=1.1*[min(waveBPRF), max(waveBPRF)]);
%     ts(waveBPRF);
%
%   Example 3:
%     % Create an IEEE 802.15.4a waveform.
%     psdu = randi([0, 1], 50, 1);
%     cfg4a = lrwpanHRPConfig(Mode='802.15.4a', ...
%                 MeanPRF=15.6, ...                % 8 candidate bursts
%                 DataRate=27.24, ...              % 1 chip per burst (PHR at 850 kbps max)
%                 Channel=9, CodeIndex=3, ...      % 3rd code with length 31, high-band mandatory channel
%                 PreambleMeanPRF=4.03, ...        % PreambleSpreadingFactor = 64
%                 PSDULength=100);                 % Input bits will be looped
%     wave4a = lrwpanWaveformGenerator(psdu, cfg4a);
%     sa = spectrumAnalyzer(SampleRate=cfg4a.SampleRate);
%     sa(wave4a);
%
%   See also lrwpanWaveformGenerator, lrwpanOQPSKConfig.

%   Copyright 2021-2022 The MathWorks, Inc.

%#codegen

  properties
    %Channel Channel number
    % Specify Channel as one of [0:3 5:6 8:10 12:14]. This property
    % constrains the allowed CodeIndex values for the BPRF and 802.15.4a
    % modes. The default is 0. Waveforms generated by
    % lrwpanWaveformGenerator are baseband and have to be upconverted to
    % the corresponding channel frequency (if transmitted).
    Channel (1, 1) double {mustBeNumeric, mustBeMember(Channel, [0:3 5:6 8:10 12:14])} = 0;
    
    %Mode Operation mode
    % Specify Mode as one of 'HPRF' (default) | 'BPRF' | '802.15.4a'. When
    % Mode is 'HPRF' (Higher Pulse Repetition Frequency in IEEE 802.15.4z),
    % MeanPRF is either 124.8 or 249.6 MHz. When Mode is 'BPRF' (Base Pulse
    % Repetition Frequency in IEEE 802.15.4a/z), MeanPRF is 62.4 MHz and
    % DataRate is 6.81 Mbps. When Mode is '802.15.4a', MeanPRF is either
    % 3.9 or 15.6 MHz, or 62.4 MHz with a DataRate different than 6.81
    % Mbps. 'BPRF' and '802.15.4a' use burst position modulation with
    % BPSK (BPM-BPSK). The 'HPRF' mode employs the HRP-ERDEV modulation
    % scheme, where chip transmissions are more regular.
    Mode {mustBeNonempty, mustBeMember(Mode, {'HPRF', 'BPRF', '802.15.4a'})} = 'HPRF'
    
    %MeanPRF Mean pulse repetition frequency in MHz (see Tables 15-3, 15-10a)
    % Specify MeanPRF in MHz as one of 3.9 | 15.6 | 62.4 | 124.8 | 249.6
    % (default). When Mode is 'HPRF', MeanPRF is either 124.8 or 249.6
    % MHz (PeakPRF/2). When Mode is 'BPRF', mean PRF is always 62.4 MHz.
    % When Mode is '802.15.4a', MeanPRF is 3.9, 15.6 or 62.4 MHz. The
    % default is 249.6 MHz (HPRF mode). For the 802.15.4a and BPRF modes,
    % MeanPRF equals PeakPRF/BurstPerSymbol = 499.2/BustsPerSymbol.
    MeanPRF (1, 1) double {mustBeNumeric, mustBeMember(MeanPRF, [3.9, 15.6, 62.4, 124.8, 249.6])} = 249.6
    
    %DataRate Payload data rate in Mbits per second (see Table 15-3)
    % Specify DataRate in Mbps as one of 0.11 | 0.85 (default) | 1.7 | 6.81
    % | 27.24. This property applies when Mode is '802.15.4a' and
    % determines the number of chips per burst. When Mode is 'BPRF',
    % data rate is always 6.81 Mbps. DataRate conveys the number of payload
    % information bits (not including parity bits) that are conveyed in a
    % unit of time. The 1.7 Mbps value is only allowed when MeanPRF equals
    % 3.9 MHz and the 27.24 Mbps value is only allowed when MeanPRF equals
    % 15.6 MHz or 62.4 MHz.
    DataRate (1, 1) double {mustBeNumeric, mustBeMember(DataRate, [0.11, 0.85, 1.7, 6.81, 27.24])} = 0.85
    
    %PHRDataRate PHR data rate in Mbits per second (see Table 15-9a)
    % Specify PHRDataRate as 0.85 (default) or 6.81. This property applies
    % for the BPRF mode only and determines the number of chips per burst
    % for the PHR. When mode is '802.15.4a', the data rate of the PHR is
    % min(0.85, DataRate). Specifically, the PHR data rate is 0.11 Mbps when
    % DataRate equals 0.11 Mbps and 0.85 Mbps otherwise. When mode is
    % 'HPRF', the PHR data rate equals the payload data rate when
    % ConstraintLength = 7 and is about half the payload data rate otherwise.
    PHRDataRate (1, 1) double {mustBeNumeric, mustBeMember(PHRDataRate, [0.85, 6.81])} = 0.85
    
    %SamplesPerPulse Number of samples per Butterworth pulse
    % Specify SamplesPerPulse as a positive integer scalar that is greater
    % than 1. This property determines how many samples are used to
    % construct an 8th-order Butterworth pulse. The sample rate of the HRP
    % waveform equals SamplesPerPulse x PeakPRF. The default is 4.
    SamplesPerPulse (1, 1) {mustBeNumeric, mustBeGreaterThan(SamplesPerPulse, 1), mustBeInteger} = 4
    
    %STSPacketConfiguration Control STS placement within the packet
    % Specify STSPacketConfiguration as one of 0 | 1 | 2 | 3. This property
    % applies when Mode is either 'HPRF' or 'BPRF'. This property
    % determines the placement of the scrambled timestamp sequence (STS)
    % within the packet. A value of 0 denotes that the STS is absent; 1 or
    % 2 denotes that the STS is placed before or after the PHR/payload
    % union, respectively; 3 denotes that the packet contains only the STS
    % (without PHR/payload). The default is 1.
    % When the STS field is enabled, it is created with:
    %    STS key = "4a5572bc90798c8e518d2449092f1b55", and
    %    STS counter ([upper96 lower32]) = ["68debd3a599939dd57fdbb0e" "2a10fac0"].
    % These values are widely used in test vectors released by IEEE.
    STSPacketConfiguration (1, 1) double {mustBeNumeric, mustBeMember(STSPacketConfiguration, 0:3)} = 1
    
    %NumSTSSegments Number of STS segments
    % Specify NumSTSSegments as one of 1 | 2 | 3 | 4. This property
    % specifies the number of contiguous STS (scrambled timestamp sequence)
    % segments. This property applies only when Mode is 'HPRF'. For the
    % BPRF mode, the number of STS segments always equals 1. For 802.15.4a,
    % the STS does not apply. The default is 1.
    NumSTSSegments (1, 1) double {mustBeNumeric, mustBeMember(NumSTSSegments, 1:4)} = 1
    
    %STSSegmentLength Length of active STS segments in chips
    % Specify STSSegmentLength in units of 512 chips as one of 16 | 32 | 64
    % | 128 | 256. This property specifies the length of each active STS
    % (scrambled timestamp sequence) segment. This property applies only
    % when Mode is 'HPRF'. For the BPRF mode (62.4 MHz), the STS segment
    % length always equals 64. For 802.15.4a, the STS does not apply. The
    % default is 64, which corresponds to 32768 chips.
    STSSegmentLength (1, 1) double {mustBeNumeric, mustBeMember(STSSegmentLength, [16 32 64 128 256])} = 64
    
    %ExtraSTSGapLength Length of extra STS gap, as a multiple of 4 chips
    % Specify ExtraSTSGapLength in units of 4 chips as a multiplier ranging
    % from 0 to 127. This property specifies the length of an optional
    % additional gap between the payload and the STS. This property applies
    % only when Mode is 'HPRF' and STSPacketConfiguration is 2. The default
    % is 0.
    ExtraSTSGapLength (1, 1) {mustBeNumeric, mustBeMember(ExtraSTSGapLength, 0:127)} = 0
    
    %ExtraSTSGapIndex Index of extra STS gap value
    % Specify ExtraSTSGapIndex as one of 0 (default) | 1 | 2 | 3. This
    % property determines which attribute conveys the ExtraSTSGapLength
    % value. It is used to construct the first two bits (A0, A1) of the PHY
    % Header (PHR). This property applies only when Mode is 'HPRF' and
    % STSPacketConfiguration is 2. The default is 0.
    ExtraSTSGapIndex (1, 1) double {mustBeNumeric, mustBeMember(ExtraSTSGapIndex, 0:3)} = 0
    
    %CodeIndex Index of used SYNC code from Tables 15-6, 15-7 and 15-7a.
    % Specify CodeIndex as one of [1:6 9:16 21:32]. Values 1-8 correspond
    % to a code that is 31 symbols long (Table 15-6); values 9-24
    % correspond to a code that is 127 symbols long (Table 15-7); values
    % 25-32 correspond to a code that is 91 symbols long (Table 15-7a). All
    % codes contain ternary symbols (-1, 0, 1). Codes 1-8 apply only when
    % Mode is '802.15.4a' and MeanPRF is less than 62.4 MHz. Codes 9-24
    % apply only when MeanPRF is 62.4 MHz. Codes 25-32 apply only when
    % Mode is BPRF or HPRF. The default is 25.
    CodeIndex (1, 1) double {mustBeNumeric, mustBeMember(CodeIndex, [1:6 9:16 21:32])} = 25;
    
    %PreambleMeanPRF Mean pulse repetition frequency (PRF) of the preamble
    % Specify PreambleMeanPRF in MHz as either 16.1 or 4.03. This property
    % applies only when PreambleCodeLength is 31, i.e., when CodeIndex is
    % less than or equal to 8 (Mode is '802.15.4a'). When
    % PreambleCodeLength is 127 or 91, PreambleMeanPRF is hidden and set to
    % 62.89 or 111.09 MHz, respectively. The default is 16.1 MHz.
    PreambleMeanPRF (1, 1) double {mustBeNumeric, mustBeMember(PreambleMeanPRF, [4.03, 16.1])} = 16.1
    
    %PreambleDuration Number of repetitions of spread preamble SYNC codes
    % Specify PreambleDuration as one of 16 | 24 | 32 | 48 | 64 | 96 | 128
    % | 256 | 1024 | 4096. When Mode is 'HPRF', only values 16, 24, 32, 48,
    % 64, 96, 128 and 256 are allowed. When Mode is 'BPRF' or '802.15.4a',
    % only values 16, 64, 1024 and 4096 are allowed. PreambleDuration
    % determines how many times the code indexed by CodeIndex is repeated,
    % after it is spread according to the PreambleSpreadingFactor.
    % PreambleDuration cannot be set to 4096 (Long) when PreambleMeanPRF is
    % 4.03 MHz. The default is 64.
    PreambleDuration (1, 1) double {mustBeNumeric, mustBeMember(PreambleDuration, [16 24 32 48 64 96 128 256 1024 4096])} = 64
    
    %SFDNumber Index of start-of-frame delimiter (SFD) choice (see Table 15-7c)
    % Specify SFDNumber as one of 0, 1, 2, 3, 4. This property determines
    % the length and value of the SFD in the synchronization header (SHR).
    % This property applies only when Mode is 'HPRF' or 'BPRF'. For the
    % BPRF mode, only values 0 and 2 are allowed; both values enable an
    % 8-symbol SFD. SFDNumber 1, 3 or 4 enable a 4-, 16-, or 32-symbol SFD,
    % respectively. When Mode is '802.15.4a' mode, a 64-symbol (long) SFD
    % is used when DataRate is 0.11 Mbps and an 8-symbol (short) SFD
    % otherwise. The default is 0.
    SFDNumber (1, 1) double {mustBeNumeric, mustBeMember(SFDNumber, [0, 1, 2, 3, 4])} = 0
    
    %Ranging Flag denoting if the PHY frame is for ranging
    % Specify Ranging as a scalar boolean. This flag denotes whether the
    % PHY frame is for ranging purposes and the value is encoded in the PHY
    % header (PHR). The default is false.
    Ranging (1,1) logical = false
    
    %ConstraintLength Flag denoting the constraint length of convolutional coding
    % Specify ConstraintLength as 3 or 7. This property applies when Mode
    % is 'HPRF'. The chosen constraint length selects between the two rate
    % 1/2 convolutional encoders in Sec. 15.3.3.3. The default is 3.
    ConstraintLength (1, 1) double {mustBeNumeric, mustBeMember(ConstraintLength, [3 7])} = 3
    
    %PSDULength Length of PHY Service Data Unit
    % Specify PSDULength as a positive integer scalar. This property
    % conveys the length of the payload in bytes. PSDULength must be no
    % greater than 4095 when Mode is 'HPRF' and ExtraSTSGapLength is zero;
    % no greater than 1023 when Mode is 'HPRF' and ExtraSTSGapLength is
    % greater than zero; and no greater than 127 otherwise. The default is
    % 127.
    PSDULength (1, 1) {mustBeNumeric, mustBeGreaterThanOrEqual(PSDULength, 0), ...
      mustBeLessThanOrEqual(PSDULength, 4095), mustBeInteger(PSDULength)} = 127;
  end
  
  properties (Dependent, SetAccess = 'private')
    %PeakPRF Peak pulse repetition frequency in MHz
    % Chips/pulses are spaced 1/(499.2 MHz) = 2ns apart, unless Mode
    % is 'HPRF' and MeanPRF is 124.8 MHz.
    PeakPRF
    
    %BurstsPerSymbol Number of bursts per symbol (see Table 15-3)
    % BurstsPerSymbol is the number of burst durations within a symbol. The
    % value represents the sum of the candidate active bursts and the
    % number of guard intervals. The number of burst durations within a
    % symbol equals the symbol duration divided with ChipsPerBurst x
    % ChipDuration, where ChipDuration = 0.2 ns. BurstsPerSymbol equals 32,
    % 128 or 8 for a MeanPRF set to 15.6 MHz, 3.9 MHz and 62.4 MHz,
    % respectively. This property applies only when Mode is 'BPRF' or
    % '802.15.4a'.
    BurstsPerSymbol
    
    %NumHopBursts Number of candidate bursts per symbol (see Table 15-3)
    % NumHopBursts is the number of candidate burst durations within a
    % symbol where transmissions may occur. The number does not include
    % guard intervals, and does not include bursts that are excluded based
    % on the value of the systematic bit. NumHopBursts equals
    % BurstsPerSymbol/4. This property applies only when Mode is 'BPRF' or
    % '802.15.4a'.
    NumHopBursts
    
    %ChipsPerBurst Number of chips per burst (see Table 15-3)
    % The number of chips per burst can take one of the following values:
    % 1, 2, 4, 8, 16, 32, 64, 128, 512. ChipsPerBurst is a scalar when data
    % rate is either 110 or 850 kb/s. It is a 2-element vector otherwise;
    % the 1st element is the ChipsPerBurst value for the PHR and the 2nd
    % element is the ChipsPerBurst value for the payload. The selected values
    % are dependent on the MeanPRF and DataRate combination. This property
    % applies only when Mode is 'BPRF' or '802.15.4a'.
    ChipsPerBurst
    
    %ChipsPerSymbol Number of chips per symbol (see Table 15-3)
    % When Mode is 'HPRF', ChipsPerSymbol is either 8, 16, or 32. When Mode
    % is 'BPRF' or '802.15.4a', the number of chips per symbol equals
    % ChipsPerBurst x BurstsPerSymbol. ChipsPerSymbol is a scalar when data
    % rate is either 110 or 850 kb/s or when ConstraintLength is 7. It is a
    % 2-element vector otherwise; the 1st element is the ChipsPerSymbol
    % value for the PHR and the 2nd element is the ChipsPerSymbol value for
    % the payload.
    ChipsPerSymbol
    
    %ConvolutionalCoding Flag for activation of the payload convolutional encoder
    % ConvolutionalCoding is a boolean denoting the activation of rate 1/2
    % convolutional encoding for the payload. Convolutional coding is
    % disabled when MeanPRF is 15.6 MHz and DataRate is 27.24 Mbps, or when
    % MeanPRF is 3.9 MHz and DataRate is 6.81 Mbps. The PHR always uses
    % convolutional encoding. The default is true.
    ConvolutionalCoding
    
    %PreambleCodeLength Length of preamble in symbols
    % PreambleCodeLength represents the length of the ternary (-1, 0, 1)
    % code field within the synchronization header (SHR), and is the length
    % of the code before spreading and repetition. PreambleCodeLength
    % equals 31 when CodeIndex is less than or equal to 8, 127 when CodeIndex is
    % between 9 and 24, and 91 otherwise. The default is 91.
    PreambleCodeLength
    
    %PreambleSpreadingFactor Length of delta function spreading code
    % The code indexed by CodeIndex is spread with a delta function that
    % has length PreambleSpreadingFactor. This property can take the
    % values: 4, 16 or 64 chips. PreambleSpreadingFactor is 4 chips when
    % PreambleCodeLength is 127 or 91, (specifically when CodeIndex is
    % greater than 8). When PreambleCodeLength is 31 (specifically, when
    % Mode is '802.15.4a'), PreambleSpreadingFactor is 16 chips when
    % PreambleMeanPRF is 16.1 MHz and 64 are chosen when PreambleMeanPRF is
    % 4.03 MHz. The default is 4.
    PreambleSpreadingFactor
    
    %SampleRate Sample rate of output waveform
    % SampleRate provides the sample rate of the output signal in Hz. The
    % default is 1.9968 GHz.
    SampleRate
  end
  
  properties (Dependent, Hidden)
    % Used for BPRF values to be reflected to MeanPRF, DataRate
    MeanPRFNum
    DataRateNum
  end
  
  properties(Constant, Hidden)
    % still needed for tab-completion
    Mode_Values = {'HPRF', 'BPRF', '802.15.4a'}
  end
  
  methods
    function obj = HRPConfig(varargin)
      obj@comm.internal.ConfigBase(varargin{:}); % call base constructor
    end

    function s = info(obj)
      %info Return information such as sample rate and modulation characteristics
      %   S = info(H) returns a structure, S, containing the values of
      %   properties that are uniquely determined by the standard, such as:
      %      - PeakPRF
      %      - BurstsPerSymbol (only for Mode equal to 'BPRF' or '802.15.4a')
      %      - NumHopBursts (only for Mode equal to 'BPRF' or '802.15.4a')
      %      - ChipsPerBurst (only for Mode equal to 'BPRF' or '802.15.4a')
      %      - ChipsPerSymbol
      %      - ConvolutionalCoding
      %      - PreambleCodeLength
      %      - PreambleSpreadingFactor
      
      readOnlyProps = {'PeakPRF', 'BurstsPerSymbol', 'NumHopBursts', 'ChipsPerBurst', ...
        'ChipsPerSymbol', 'ConvolutionalCoding', 'PreambleCodeLength', ...
        'PreambleSpreadingFactor'};

      for idx = 1:numel(readOnlyProps)
        thisProp = readOnlyProps{idx};
        if ~isInactiveProperty(obj, thisProp)
          s.(thisProp) = obj.(thisProp);
        end
      end
    end
    
    function obj = set.Mode(obj, val)
      % MeanPRF can become dependent and conditionally read-only. A private
      % property would be needed to cache the sets of MeanPRF when it can
      % tune (HPRF).
      obj.Mode = val;
    end
    
    function peak = get.PeakPRF(obj)
      peak = 499.2;
      if strcmp(obj.Mode, 'HPRF') && obj.MeanPRFNum == 124.8
        peak = peak/2;
      end
    end

    function prfNum = get.MeanPRFNum(obj)
      if strcmp(obj.Mode, 'BPRF')
        prfNum = 62.4;
      else
        prfNum = obj.MeanPRF;
      end
    end
    
    function r = get.DataRateNum(obj)
      if strcmp(obj.Mode, 'BPRF')
        r = 6810;
      else
        r = obj.DataRate*1e3; % handle with kbps internally
      end
    end
    
    function len = get.PreambleCodeLength(obj)
      if obj.CodeIndex <= 8
        len = 31;
      elseif obj.CodeIndex <= 24
        len = 127;
      else % 25-32
        len = 91;
      end
    end
    
    function bps = get.BurstsPerSymbol(obj)
      switch obj.MeanPRFNum
        case 15.6
          bps = 32;
        case 3.9
          bps = 128;
        otherwise % 62.4MHz
          bps = 8;
      end
    end
    function n = get.NumHopBursts(obj)
      n = obj.BurstsPerSymbol/4;
    end

    function cpb = get.ChipsPerBurst(obj)
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
    
    function cps = get.ChipsPerSymbol(obj)
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
    
    function b = get.ConvolutionalCoding(obj)
      % No coding for some cases, as per Table 15-3
      b = ~((obj.MeanPRFNum == 3.9  && obj.DataRateNum == 6810) || ...
            (obj.MeanPRFNum == 15.6 && obj.DataRateNum == 27240));
    end
    
    function L = get.PreambleSpreadingFactor(obj)
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
    
    function Fs = get.SampleRate(obj)
      Fs = obj.SamplesPerPulse*obj.PeakPRF;
      Fs = Fs*1e6;
    end
    
    function validateConfig(obj)
      % Cross-property validations
      
      % Mode vs MeanPRF
      if strcmp(obj.Mode, 'HPRF') && any(obj.MeanPRFNum == [3.9, 15.6, 62.4]) || ...
         strcmp(obj.Mode, '802.15.4a') && any(obj.MeanPRFNum == [124.8, 249.6])
        error(message('zigbee:LRWPAN:InvalidModeMeanPRF'));
      end
      % MeanPRF vs DataRate
      if obj.MeanPRFNum == 3.9 && obj.DataRateNum == 27240 || ...
         obj.MeanPRFNum  > 3.9 && obj.DataRateNum == 1700
        % See Table 15-3
        error(message('zigbee:LRWPAN:InvalidMeanPRFDataRate'));
      end
      
      % CodeIndex vs MeanPRF
      if (obj.CodeIndex <= 8 && obj.MeanPRFNum >= 62.4) || ...
         (obj.CodeIndex > 8 && obj.CodeIndex < 25 && obj.MeanPRFNum~=62.4) || ...
         (obj.CodeIndex >=25 && strcmp(obj.Mode, '802.15.4a'))
        % See Table 15-3 for length 127 codes; see Sec. 15.2.6.2 for length 91 codes
        error(message('zigbee:LRWPAN:InvalidCodeIndexMeanPRF'));
      end
      
      % CodeIndex vs ChannelNumber
      switch obj.CodeIndex
        case {1, 2}
          allowedChannels = [0, 1, 8, 12];
        case {3, 4}
          allowedChannels = [2, 5, 9, 13];
        case {5, 6}
          allowedChannels = [3, 6, 10, 14];
        otherwise
          % everything is allowed
          allowedChannels = setdiff(0:15, [4 7 11 15]);
      end
      if ~ismember(obj.Channel, allowedChannels)
        error(message('zigbee:LRWPAN:ChannelCodeMismatch', obj.Channel, obj.CodeIndex));
      end
      
      if obj.MeanPRFNum == 62.4 && obj.DataRateNum ~= 6810
        % Legacy 15.4a 62.4 rate (not BPRF, see Table 15-9a)
        if obj.CodeIndex > 25
          error(message('zigbee:LRWPAN:InvalidMeanPRF62dot4'));
        end
      end
      
      % PreambleDuration:
      if strcmp(obj.Mode, 'HPRF') && any(obj.PreambleDuration == [1024 4096]) || ...
        ~strcmp(obj.Mode, 'HPRF') && any(obj.PreambleDuration == [24 32 48 96 128 256])  || ...
        ~strcmp(obj.Mode, 'HPRF') && obj.PreambleDuration == 4096 && obj.CodeIndex <= 8 && obj.PreambleMeanPRF == 4.03
         % HPRF & PSR, see Sec. 15.2.6.2
         % non-HPRF values, see Table 15.5
         error(message('zigbee:LRWPAN:InvalidNSync'));
      end
      
      % Mode vs SFDNumber
      if strcmp(obj.Mode, 'BPRF') && ~any(obj.SFDNumber==[0 2])
        error(message('zigbee:LRWPAN:InvalidSFD'));
      end
      
      % PSDULength
      if (~strcmp(obj.Mode, 'HPRF') && obj.PSDULength > (2^7 - 1)) ||  ...
          (strcmp(obj.Mode, 'HPRF') && obj.STSPacketConfiguration==2 && obj.ExtraSTSGapLength>0 && obj.PSDULength > (2^10 -1))
        error(message('zigbee:LRWPAN:InvalidPSDULength'))
      end
    end
  end

  methods (Hidden)
    function flag = isInactivePropertyPublic(obj, prop)
      % Controls the conditional display of properties
      % Public, to share with Wireless Waveform Generator App

      flag = false;
      
      if strcmp(prop, 'MeanPRF')
        flag = strcmp(obj.Mode, 'BPRF');
      end
      
      if strcmp(prop, 'DataRate')
        flag = ~strcmp(obj.Mode, '802.15.4a');
      end
      
      if strcmp(prop, 'PHRDataRate')
        flag = ~strcmp(obj.Mode, 'BPRF');
      end
      
      if any(strcmp(prop, {'BurstsPerSymbol', 'NumHopBursts', 'ChipsPerBurst'}))
        flag = strcmp(obj.Mode, 'HPRF');
      end
      
      if any(strcmp(prop, {'STSPacketConfiguration', 'SFDNumber'}))
        flag = strcmp(obj.Mode, '802.15.4a');
      end
      
      if any(strcmp(prop, {'ExtraSTSGapLength', 'ExtraSTSGapIndex'}))
        flag = ~strcmp(obj.Mode, 'HPRF') || obj.STSPacketConfiguration~=2;
      end
      
      if any(strcmp(prop, {'NumSTSSegments', 'STSSegmentLength'}))
        flag = ~strcmp(obj.Mode, 'HPRF')  || obj.STSPacketConfiguration == 0;
      end
      
      if strcmp(prop, 'PreambleMeanPRF')
        flag = obj.CodeIndex > 8;
      end
      
      if any(strcmp(prop, {'ConstraintLength'})) % Applies only for HPRF
        flag = ~strcmp(obj.Mode, 'HPRF');
      end
    end
  end
  
  methods (Access=protected)

    function groups = getPropertyGroups(obj)
      % override, to allow for STS group

      mainGroupNames = {'Channel', 'Mode', 'MeanPRF', 'DataRate', 'PHRDataRate', ...
            'SamplesPerPulse', 'CodeIndex', 'PreambleMeanPRF', 'PreambleDuration', ...
            'SFDNumber', 'Ranging', 'ConstraintLength', 'PSDULength'};

      stsGroupNames = {'STSPacketConfiguration', 'NumSTSSegments', 'STSSegmentLength', ...
                'ExtraSTSGapLength', 'ExtraSTSGapIndex'};

      readOnlyNames = {'SampleRate'};

      if strcmp(obj.Mode, '802.15.4a')
        stsGroup = [];
      else
        stsGroup = getGroup(stsGroupNames, 'STS:');
      end
      groups = [getGroup(mainGroupNames) stsGroup ...;
                getGroup(readOnlyNames, getString(message('shared_channel:ConfigBase:ROProperties')))];

      function group = getGroup(groupNames, varargin)
        v = cellfun(@(x) obj.(x), groupNames, 'UniformOutput', false);
        active = cellfun(@(x) ~obj.isInactiveProperty(x), groupNames);
        theseProps = cell2struct(v(active), groupNames(active), 2);
        if nargin == 1
          group = matlab.mixin.util.PropertyGroup(theseProps);
        else
          group = matlab.mixin.util.PropertyGroup(theseProps, varargin{1});
        end
      end
    end

    function flag = isInactiveProperty(obj, prop)
      flag = isInactivePropertyPublic(obj, prop);
    end
  end

  methods(Static,Hidden)
    function obj = loadobj(s)
      obj = HRPConfig;
      obj.Channel                 = s.Channel;
      obj.Mode                    = s.Mode;
      
      isPre23a = isfield(s, 'ActiveSTSLength');
      if isstruct(s) && isPre23a
        % Pre-R2023a, the following properties where char, with MHz/Mbps suffix.
        mhzStr = 'MHz';
        mbpsStr = 'Mbps';
        obj.MeanPRF                 = str2double(s.MeanPRF(1:end-length(mhzStr)));
        obj.DataRate                = str2double(s.DataRate(1:end-length(mbpsStr)));
        obj.PHRDataRate             = str2double(s.PHRDataRate(1:end-length(mbpsStr)));
        obj.PreambleMeanPRF         = str2double(s.PreambleMeanPRF(1:end-length(mhzStr)));

        % Property name change in 23a
        obj.STSSegmentLength      = s.ActiveSTSLength;

        % PSDULength was in bits, convert to bytes
        obj.PSDULength            = s.PSDULength/8;
      else
        obj.MeanPRF               = s.MeanPRF;
        obj.DataRate              = s.DataRate;
        obj.PHRDataRate           = s.PHRDataRate;
        obj.PreambleMeanPRF       = s.PreambleMeanPRF;
        obj.STSSegmentLength      = s.STSSegmentLength;
        obj.PSDULength            = s.PSDULength;
      end

      obj.SamplesPerPulse         = s.SamplesPerPulse;
      obj.STSPacketConfiguration  = s.STSPacketConfiguration;
      obj.NumSTSSegments          = s.NumSTSSegments;

      obj.ExtraSTSGapLength       = s.ExtraSTSGapLength;
      obj.ExtraSTSGapIndex        = s.ExtraSTSGapIndex;
      obj.CodeIndex               = s.CodeIndex;
      obj.PreambleDuration        = s.PreambleDuration;
      obj.SFDNumber               = s.SFDNumber;
      obj.Ranging                 = s.Ranging;
      obj.ConstraintLength        = s.ConstraintLength;
    end
  end
end

