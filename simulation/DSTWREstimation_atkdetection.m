function [EstRange,PHRflag,SFDflag] = DSTWREstimation_atkdetection(cfg,cfg_ATK,STSmode,MPEP,PAPR,num,SIR_STS,ATKdelay,corrprewin,firstzeros,lastzeros,....
    UWBChannel,ATKUWBChannel,SNR_SHR,SIR_SHR,delaylen,bits,thr,net)
%% Data preparation
data = randi([0 1],999,1);
PSDULength = ceil(length(data)/8);
data_pad = [data;zeros(PSDULength*8-length(data),1)];
PSDU = data_pad;

if(STSmode == 0)
    STSzerolen = 128*4*4;
else
    STSzerolen = 0;
end

[wave,SYNCbit,SFDbit,STSbit,SYNC,SFD,STS,power_SHR,power_STS,length_symbol] = UWBwaveGEN(cfg,PSDU,STSmode);

%% Reference window
SYNCwindow = SYNCbit;
SFDwindow = SFDbit;
STSwindow = STSbit;
SYNCSFDlen = (length(SYNC)+length(SFD))*cfg.SamplesPerPulse;

%% Last CIR obtain
% Response Frame
wave_respon = [zeros(firstzeros,1);wave;zeros(lastzeros,1)];

% UWB Channel with Attack
% Generate ATKwave
power_ATKSHR = power_SHR/(10.^(SIR_SHR/10));
power_ATKSTS = power_STS/(10.^(SIR_STS/10));
ATKwave = ATKwavegeneration(cfg_ATK,num,STSmode ...
    ,firstzeros,ATKdelay,length(wave_respon),power_ATKSHR,power_ATKSTS);
ATKwave = [zeros(delaylen,1);ATKwave];
wave_respon = [zeros(delaylen,1);wave_respon];

% channel
rxSignal = filter(UWBChannel, 1, wave_respon);
power_noise = power_SHR/(10.^(SNR_SHR/10));
Gaussiannoise = wgn(length(rxSignal),1,power_noise,'linear');
rxSignal_noise = rxSignal+Gaussiannoise;

% add attack
ATKwave_rx = filter(ATKUWBChannel, 1, ATKwave);
wave_rx_ATK = ATKwave_rx+rxSignal_noise;

% Response Frame Demodulation
corrlen = 700;
Rx = ReceiverProcess(wave_rx_ATK,...
    cfg,length(SYNC),length(SFD),length(STS),SYNCwindow,SFDwindow,STSwindow,corrlen,PAPR,MPEP,STSzerolen,corrprewin,firstzeros,1);
CIR_initiator = abs(Rx.STScorres)./max(abs(Rx.STScorres));

%% Poll with CIR
CIRbits_initiator = getQuantiCIR(CIR_initiator,net,bits);
PSDULength = 125;
data_pad = [CIRbits_initiator;zeros(PSDULength*8-length(data),1)];
PSDU_poll = data_pad;

[wave_poll,SYNCbit,SFDbit,STSbit,SYNC,SFD,STS,power_SHR,power_STS,length_symbol] = UWBwaveGEN(cfg,PSDU_poll,STSmode);
wave_poll = [zeros(corrprewin,1);wave_poll];
Ttx1 = 1;

%% channel
% delay
wave_poll = [zeros(delaylen,1);wave_poll];

% UWB channel
rxSignal = filter(UWBChannel, 1, wave_poll);
power_noise = power_SHR/(10.^(SNR_SHR/10));
Gaussiannoise = wgn(length(rxSignal),1,power_noise,'linear');
rxSignal_noise = rxSignal+Gaussiannoise;

%% Poll Frame Demodulation
corrlen = 700;
Rx_poll = ReceiverProcess(rxSignal_noise,...
    cfg,length(SYNC),length(SFD),length(STS),SYNCwindow,SFDwindow,STSwindow,corrlen,PAPR,MPEP,STSzerolen,corrprewin,corrprewin,Ttx1);

%% Responder Attack Detection
CIR_responder = abs(Rx_poll.STScorres)./max(abs(Rx_poll.STScorres));
CIRbits_responder = getQuantiCIR(CIR_responder,net,bits);
errorbits = numel(find(CIRbits_responder ~= CIRbits_initiator));
if(errorbits > thr) % attack
    EstRange = 0;
    PHRflag = 0;
    SFDflag = 0;
    return;
end

tau = round(1e-3*cfg.SampleRate);
Treply1 = tau;
Ttx2 = Rx_poll.STSidx+Treply1-SYNCSFDlen;

%% Response Frame
wave_respon = [zeros(firstzeros,1);wave;zeros(lastzeros,1)];

%% UWB Channel with Attack
% Generate ATKwave
power_ATKSHR = power_SHR/(10.^(SIR_SHR/10));
power_ATKSTS = power_STS/(10.^(SIR_STS/10));
ATKwave = ATKwavegeneration(cfg_ATK,num,STSmode ...
    ,firstzeros,ATKdelay,length(wave_respon),power_ATKSHR,power_ATKSTS);
ATKwave = [zeros(delaylen,1);ATKwave];
wave_respon = [zeros(delaylen,1);wave_respon];

% channel
rxSignal = filter(UWBChannel, 1, wave_respon);
power_noise = power_SHR/(10.^(SNR_SHR/10));
Gaussiannoise = wgn(length(rxSignal),1,power_noise,'linear');
rxSignal_noise = rxSignal+Gaussiannoise;

% add attack
ATKwave_rx = filter(ATKUWBChannel, 1, ATKwave);
wave_rx_ATK = ATKwave_rx+rxSignal_noise;

%% Response Frame Demodulation
corrlen = 700;
Rx_respon = ReceiverProcess(wave_rx_ATK,...
    cfg,length(SYNC),length(SFD),length(STS),SYNCwindow,SFDwindow,STSwindow,corrlen,PAPR,MPEP,STSzerolen,corrprewin,firstzeros,Ttx2);

% SFD and PHR check
[Rx_respon.PHRsuccessflag,phrEnd, phrCW,ternarySymbols] = ReceiverPHRRecover(Rx_respon,cfg,length_symbol,50);
Rx_respon.SFDsuccessflag = CheckSFD(Rx_respon);

% % demodulation
% payloadStart = phrEnd+1;
% PSDU_poll_rec = decodePayload(ternarySymbols, payloadStart, phrCW, cfgHPRF);
% CIRbits_rec = PSDU_poll_rec(1:32*bits);

Treply2 = tau;
Ttx3 = Rx_respon.STSidx+Treply2-SYNCSFDlen;

%% Final Frame
wave_final = [zeros(corrprewin,1);wave];

%% UWB channel
% delay
wave_final = [zeros(delaylen,1);wave_final];

% channel
rxSignal = filter(UWBChannel, 1, wave_final);
power_noise = power_SHR/(10.^(SNR_SHR/10));
Gaussiannoise = wgn(length(rxSignal),1,power_noise,'linear');
rxSignal_noise = rxSignal+Gaussiannoise;

%% Final Frame Demodulation
corrlen = 700;
Rx_final = ReceiverProcess(rxSignal_noise,...
    cfg,length(SYNC),length(SFD),length(STS),SYNCwindow,SFDwindow,STSwindow,corrlen,PAPR,MPEP,STSzerolen,corrprewin,corrprewin,Ttx3);

Tround1 = Rx_respon.STSidx-(Ttx1+SYNCSFDlen);
Tround2 = Rx_final.STSidx-(Ttx2+SYNCSFDlen);

%% Calculate Range
Tround1 = Tround1/cfg.SampleRate;
Tround2 = Tround2/cfg.SampleRate;
Treply1 = Treply1/cfg.SampleRate;
Treply2 = Treply2/cfg.SampleRate;
Tprop = (Tround1*Tround2-Treply1*Treply2)/(Tround1+Tround2+Treply1+Treply2);

PHRflag = Rx_respon.PHRsuccessflag;
SFDflag = Rx_respon.SFDsuccessflag;
EstRange = Tprop*3e8;

end