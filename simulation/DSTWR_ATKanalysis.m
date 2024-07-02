%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Testing the GHOST PEAK attack success rate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
clc
clear
close all

%% Parmeter
load H_channel_LOS.mat;
load BPRFConfigresult.mat;

% range
TrueRange = 10;
delaylen = round(TrueRange/3e8*cfg.SampleRate);
TrueRange = delaylen*3e8/cfg.SampleRate;

mode = 'BPRF';
STSmode = 0;

MPEP = 0.25;
PAPR = 2;

SNR_SHR = -10; % 10m
SIR_SHR = 20;
SIR_STSrange = -20:-1:-30;

STSnum = 200;

corrprewin = 200; % 预留窗口

% Attacker
ATKdelayrange = [-5000,-4000,-3000,-2000,-1000,0,1000,2000,3000,4000,5000];

% zero pad
firstzeros = 10000;
lastzeros = 10000;

%% DSTWR Process
EstRangedata = zeros(length(ATKdelayrange),length(SIR_STSrange),STSnum);
PHRsuccessflag = true(length(ATKdelayrange),length(SIR_STSrange),STSnum);
SFDsuccessflag = true(length(ATKdelayrange),length(SIR_STSrange),STSnum);
for SIR_STSidx = 1:length(SIR_STSrange)
for ATKdelayidx = 1:length(ATKdelayrange)
SIR_STS = SIR_STSrange(SIR_STSidx);
ATKdelay = ATKdelayrange(ATKdelayidx); 
parfor num = 1:STSnum

[EstRange,PHRflag,SFDflag] = DSTWREstimation(cfg,cfg_ATK,STSmode,MPEP,PAPR,num,SIR_STS,ATKdelay,corrprewin,firstzeros,lastzeros,....
    UWBChannel,ATKUWBChannel,SNR_SHR,SIR_SHR,delaylen);
EstRangedata(ATKdelayidx,SIR_STSidx,num) = EstRange;
PHRsuccessflag(ATKdelayidx,SIR_STSidx,num) = PHRflag;
SFDsuccessflag(ATKdelayidx,SIR_STSidx,num) = SFDflag;

end
end
SIR_STSidx
end

save('ATKresult(LOSrange10)','EstRangedata','PHRsuccessflag','SFDsuccessflag')

% numel(find(EstRangedata<TrueRange-5 & EstRangedata>0))/numel(EstRangedata)*100 