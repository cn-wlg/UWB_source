clc
clear
close all

%% Load
load SYNCLOSCIRdataset_total
load SYNCLOSCIRdataset_atk_total
load STSnumdataset_total
load STSLOSCIRdataset_total
load STSLOSCIRdataset_atk_total
load SFDLOSCIRdataset_total
load SFDLOSCIRdataset_atk_total
load ATKdelaydataset_total

load UWBLOSChannelset_new.mat;
load BPRFConfigresult.mat;
load model(len700output32sample16000)
load Parametersetting.mat

%% Parmeter
SIR_STS = -25;

%% Wave Preparation
[wave,~,~,~,SYNC,SFD,STS,power_SHR,power_STS,length_symbol] = UWBwaveGEN(cfg,PSDU,STSmode);
length_SYNC = length(SYNC);
length_SFD = length(SFD);
length_STS = length(STS);
length_symbol = 15000;

%% DSTWR Process
len = 10000;
EstRangedata = zeros(len,3,6);
PHRsuccessflag = true(len,3,6);
SFDsuccessflag = true(len,3,6);
SNRrange = -10:4:10;

for idx = 1:6
EstRangedatatemp1 = zeros(len,1);
PHRsuccessflagtemp1 = true(len,1);
SFDsuccessflagtemp1 = true(len,1);
EstRangedatatemp2 = zeros(len,1);
PHRsuccessflagtemp2 = true(len,1);
SFDsuccessflagtemp2 = true(len,1);
EstRangedatatemp3 = zeros(len,1);
PHRsuccessflagtemp3 = true(len,1);
SFDsuccessflagtemp3 = true(len,1);
SNR_SHR = SNRrange(idx);
for i = 1:len
% Preparation
ATKdelay = ATKdelaydataset_total{idx,i};
num = STSnumdataset_total{idx,i};
SYNCCIR = SYNCLOSCIRdataset_total{idx,i}; 
SFDCIR = SFDLOSCIRdataset_total{idx,i};
STSCIR = STSLOSCIRdataset_total{idx,i};
SYNCCIR_atk = SYNCLOSCIRdataset_atk_total{idx,i}; 
SFDCIR_atk = SFDLOSCIRdataset_atk_total{idx,i};
STSCIR_atk = STSLOSCIRdataset_atk_total{idx,i};
UWBChannel = UWBChannelset{i};
ATKUWBChannel = ATKUWBChannelset{i};

%% Only Attack
[EstRange,PHRflag,SFDflag] = DSTWREstimationwithCIR(wave,length_SYNC,length_SFD,length_STS,...
    length_symbol,cfg,cfg_ATK,STSmode,MPEP,PAPR,num,SIR_STS,ATKdelay,corrprewin,firstzeros,lastzeros,....
    UWBChannel,ATKUWBChannel,SNR_SHR,SIR_SHR,delaylen,power_SHR,power_STS,...
    SYNCCIR,SFDCIR,STSCIR,SYNCCIR_atk,SFDCIR_atk,STSCIR_atk);
EstRangedatatemp1(i) = EstRange;
PHRsuccessflagtemp1(i) = PHRflag;
SFDsuccessflagtemp1(i) = SFDflag;

%% Secure1
% 4bit
bits = 4;
thr = 15;
[EstRange,PHRflag,SFDflag] = DSTWREstimationwithCIR_atkdetection(wave,length_SYNC,length_SFD,length_STS,...
    length_symbol,cfg,cfg_ATK,STSmode,MPEP,PAPR,num,SIR_STS,ATKdelay,corrprewin,firstzeros,lastzeros,....
    UWBChannel,ATKUWBChannel,SNR_SHR,SIR_SHR,delaylen,power_SHR,power_STS,...
    SYNCCIR,SFDCIR,STSCIR,SYNCCIR_atk,SFDCIR_atk,STSCIR_atk,bits,thr,net);
EstRangedatatemp2(i) = EstRange;
PHRsuccessflagtemp2(i) = PHRflag;
SFDsuccessflagtemp2(i) = SFDflag;

% 1bit
bits = 1;
thr = 3;
[EstRange,PHRflag,SFDflag] = DSTWREstimationwithCIR_atkdetection(wave,length_SYNC,length_SFD,length_STS,...
    length_symbol,cfg,cfg_ATK,STSmode,MPEP,PAPR,num,SIR_STS,ATKdelay,corrprewin,firstzeros,lastzeros,....
    UWBChannel,ATKUWBChannel,SNR_SHR,SIR_SHR,delaylen,power_SHR,power_STS,...
    SYNCCIR,SFDCIR,STSCIR,SYNCCIR_atk,SFDCIR_atk,STSCIR_atk,bits,thr,net);
EstRangedatatemp3(i) = EstRange;
PHRsuccessflagtemp3(i) = PHRflag;
SFDsuccessflagtemp3(i) = SFDflag;
end
EstRangedata(:,1,idx) = EstRangedatatemp1;
PHRsuccessflag(:,1,idx) = PHRsuccessflagtemp1;
SFDsuccessflag(:,1,idx) = SFDsuccessflagtemp1;
EstRangedata(:,2,idx) = EstRangedatatemp2;
PHRsuccessflag(:,2,idx) = PHRsuccessflagtemp2;
SFDsuccessflag(:,2,idx) = SFDsuccessflagtemp2;
EstRangedata(:,3,idx) = EstRangedatatemp3;
PHRsuccessflag(:,3,idx) = PHRsuccessflagtemp3;
SFDsuccessflag(:,3,idx) = SFDsuccessflagtemp3;
end

save('ATKdetectionsuccessresult_SIR-25(LOSrange10)','EstRangedata','PHRsuccessflag','SFDsuccessflag')

% numel(find(EstRangedata<TrueRange-5 & EstRangedata>0))/numel(EstRangedata)*100 