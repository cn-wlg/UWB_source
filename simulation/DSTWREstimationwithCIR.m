function [EstRange,PHRflag,SFDflag] = DSTWREstimationwithCIR(wave,length_SYNC,length_SFD,length_STS,...
    length_symbol,cfg,cfg_ATK,STSmode,MPEP,PAPR,num,SIR_STS,ATKdelay,corrprewin,firstzeros,lastzeros,....
    UWBChannel,ATKUWBChannel,SNR_SHR,SIR_SHR,delaylen,power_SHR,power_STS,...
    SYNCCIR,SFDCIR,STSCIR,SYNCCIR_atk,SFDCIR_atk,STSCIR_atk)
SYNCSFDlen = (length_SYNC+length_SFD)*cfg.SamplesPerPulse;

%% Poil Frame Demodulation
Ttx1 = 1;
Rx_poil = ReceiverProcesswithCIR(cfg,SYNCCIR,SFDCIR,STSCIR,...
    length_SYNC,length_SFD,PAPR,MPEP,corrprewin,Ttx1,delaylen);

tau = round(1e-3*cfg.SampleRate);
Treply1 = tau;
Ttx2 = Rx_poil.STSidx+Treply1-SYNCSFDlen;

%% Response Frame
wave_respon = [zeros(firstzeros,1);wave;zeros(lastzeros,1)];

%% UWB Channel with Attack
% Generate ATKwave
power_ATKSHR = power_SHR/(10.^(SIR_SHR/10));
power_ATKSTS = power_STS/(10.^(SIR_STS/10));
ATKwave = ATKwavegeneration(cfg_ATK,num,STSmode ...
    ,firstzeros,ATKdelay,length(wave_respon),power_ATKSHR,power_ATKSTS);

% channel
rxSignal = filter(UWBChannel, 1, wave_respon);
power_noise = power_SHR/(10.^(SNR_SHR/10));
Gaussiannoise = wgn(length(rxSignal),1,power_noise,'linear');
rxSignal_noise = rxSignal+Gaussiannoise;

% add attack
ATKwave_rx = filter(ATKUWBChannel, 1, ATKwave);
wave_rx_ATK = ATKwave_rx+rxSignal_noise;

%% Response Frame Demodulation
Rx_respon = ReceiverProcesswithCIR(cfg,SYNCCIR_atk,SFDCIR_atk,STSCIR_atk,...
    length_SYNC,length_SFD,PAPR,MPEP,corrprewin,Ttx2,delaylen);

wave_rx_match = butterworthmatchFilter(wave_rx_ATK, cfg.SamplesPerPulse);
wave_rx_match = wave_rx_match(firstzeros-corrprewin+1:end);
wave_rx_match = wave_rx_match(Rx_respon.SYNCidxzero-1+(length_SYNC+length_SFD+length_STS)*cfg.SamplesPerPulse-corrprewin:end);

% SFD and PHR check
%Rx_respon.PHRsuccessflag = ReceiverPHRRecover(wave_rx_match,STSCIR_atk,cfg,length_symbol,50);
Rx_respon.PHRsuccessflag = ReceiverPHRRecover(wave_rx_match,cfg,length_symbol,50);
Rx_respon.SFDsuccessflag = CheckSFD(Rx_respon);

Treply2 = tau;
Ttx3 = Rx_respon.STSidx+Treply2-SYNCSFDlen;

%% Final Frame Demodulation
Rx_final = ReceiverProcesswithCIR(cfg,SYNCCIR,SFDCIR,STSCIR,...
    length_SYNC,length_SFD,PAPR,MPEP,corrprewin,Ttx3,delaylen);

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