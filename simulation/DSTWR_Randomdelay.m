%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Testing the success rate of the GHOST PEAK attack after random time-hopping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
clc
clear
close all

%% Parmeter
load UWBChannelset.mat;
load BPRFConfigresult.mat;

% range
TrueRange = 10;
delaylen = round(TrueRange/3e8*cfg.SampleRate);
TrueRange = delaylen*3e8/cfg.SampleRate;

mode = 'BPRF';
STSmode = 0; %if 0 STS has zero pads

MPEP = 0.25;
PAPR = 2;

% SNR_SHRrange = [-10:4:10];
SNR_SHRrange = -10;
SIR_SHR = 20;
SIR_STS = -25; % attack power

STSnum = 1000;

corrprewin = 200; % pre zeros window

% Attacker
ATKdelayrange = -2000:2000; % -1us~1us

% zero pad
firstzeros = 500000;
lastzeros = 10000;

% security  
bits = 4;
thr = 15;

len = 100000;

%% DSTWR Process
EstRangedata = zeros(len,length(SNR_SHRrange));
PHRsuccessflag = true(len,length(SNR_SHRrange));
SFDsuccessflag = true(len,length(SNR_SHRrange));

for SNRidx = 1:length(SNR_SHRrange)
SNR_SHR = SNR_SHRrange(SNRidx);
for i = 1:100000
UWBChannel = UWBChannelset{i};
ATKUWBChannel = ATKUWBChannelset{i};
ATKdelay = ATKdelayrange(randperm(length(ATKdelayrange),1));
num = randperm(STSnum,1);

[EstRange,PHRflag,SFDflag] = DSTWREstimation_randomdelay(cfg,cfg_ATK,STSmode,MPEP,PAPR,num,SIR_STS,ATKdelay,corrprewin,firstzeros,lastzeros,....
    UWBChannel,ATKUWBChannel,SNR_SHR,SIR_SHR,delaylen);
EstRangedata(i,SNRidx) = EstRange;
PHRsuccessflag(i,SNRidx) = PHRflag;
SFDsuccessflag(i,SNRidx) = SFDflag;

end
SNRidx
end

% save('ATKsuccessresult_SIR-25(LOSrange10)','EstRangedata','PHRsuccessflag','SFDsuccessflag')

% numel(find(EstRangedata<TrueRange-5 & EstRangedata>0))/numel(EstRangedata)*100 