function [EstRange,PHRflag,SFDflag] = DSTWREstimation_randomdelay(cfg,cfg_ATK,STSmode,MPEP,PAPR,num,SIR_STS,ATKdelay,corrprewin,firstzeros,lastzeros,....
    UWBChannel,ATKUWBChannel,SNR_SHR,SIR_SHR,delaylen)
%% Data preparation
data = randi([0 1], 999, 1);
PSDULength = ceil(length(data)/8);
data_pad = [data;zeros(PSDULength*8-length(data),1)];
PSDU = data_pad;

if(STSmode == 0)
    STSzerolen = 128*4*4;
else
    STSzerolen = 0;
end

%% Poil Frame
[wave,SYNCbit,SFDbit,STSbit,SYNC,SFD,STS,power_SHR,power_STS,length_symbol] = UWBwaveGEN(cfg,PSDU,STSmode);
wave_poil = [zeros(corrprewin,1);wave];
Ttx1 = 1;

%% Reference window
SYNCwindow = SYNCbit;
SFDwindow = SFDbit;
STSwindow = STSbit;
SYNCSFDlen = (length(SYNC)+length(SFD))*cfg.SamplesPerPulse;

%% channel
% delay
wave_poil = [zeros(delaylen,1);wave_poil];

% UWB channel
rxSignal = filter(UWBChannel, 1, wave_poil);
power_noise = power_SHR/(10.^(SNR_SHR/10));
Gaussiannoise = wgn(length(rxSignal),1,power_noise,'linear');
rxSignal_noise = rxSignal+Gaussiannoise;

%% Poil Frame Demodulation
corrlen = 700;
Rx_poil = ReceiverProcess(rxSignal_noise,...
    cfg,length(SYNC),length(SFD),length(STS),SYNCwindow,SFDwindow,STSwindow,corrlen,PAPR,MPEP,STSzerolen,corrprewin,corrprewin,Ttx1);

tau = round(1e-3*cfg.SampleRate);
Treply1 = tau;
Ttx2 = Rx_poil.STSidx+Treply1-SYNCSFDlen;

%% Response Frame
wave_respon = [zeros(firstzeros,1);wave;zeros(lastzeros,1)];

%% Random Delay
% securedelayrange = 15:20;
% securedelay = securedelayrange(randperm(length(securedelayrange),1))*2000; % rand delay
securedelay = 0.2*2e6;

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
Rx_respon1 = ReceiverProcess(wave_rx_ATK,...
    cfg,length(SYNC),length(SFD),length(STS),SYNCwindow,SFDwindow,STSwindow,corrlen,PAPR,MPEP,STSzerolen,corrprewin,firstzeros,Ttx2);
% Rx_respon = ReceiverProcess_AE(wave_rx_ATK,...
%     cfg,length(SYNC),length(SFD),length(STS),SYNCwindow,SFDwindow,STSwindow,corrlen,PAPR,MPEP,STSzerolen,corrprewin,firstzeros,Ttx2,net);

%% UWB Channel with Attack
% Generate ATKwave
power_ATKSHR = power_SHR/(10.^(SIR_SHR/10));
power_ATKSTS = power_STS/(10.^(SIR_STS/10));
ATKwave = ATKwavegeneration(cfg_ATK,num,STSmode ...
    ,firstzeros-securedelay,ATKdelay,length(wave_respon),power_ATKSHR,power_ATKSTS);
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
% Rx_respon = ReceiverProcess_AE(wave_rx_ATK,...
%     cfg,length(SYNC),length(SFD),length(STS),SYNCwindow,SFDwindow,STSwindow,corrlen,PAPR,MPEP,STSzerolen,corrprewin,firstzeros,Ttx2,net);

fontsize_label = 8;
plot(abs(Rx_respon.STScorres),'b',LineWidth=1);
figure;
subplot(311)
plot(abs(Rx_respon1.STScorres),'b',LineWidth=1);
xlabel('\fontname{宋体}采样点','FontSize',fontsize_label,'interpreter','tex');
ylabel('\fontname{宋体}归一化幅度','FontSize',fontsize_label,'interpreter','tex');
subtitle('\fontname{宋体}攻击后的\fontname{Times new roman}CIR','FontSize',fontsize_label,'interpreter','tex')
subplot(312)
plot(abs(Rx_respon.STScorres),'b',LineWidth=1);
xlabel('\fontname{宋体}采样点','FontSize',fontsize_label,'interpreter','tex');
ylabel('\fontname{宋体}归一化幅度','FontSize',fontsize_label,'interpreter','tex');
subtitle('\fontname{宋体}经过自编码器处理的\fontname{Times new roman}CIR','FontSize',fontsize_label,'interpreter','tex')
subplot(313)
plot(abs(Rx_poil.STScorres),'b',LineWidth=1);
xlabel('\fontname{宋体}采样点','FontSize',fontsize_label,'interpreter','tex');
ylabel('\fontname{宋体}归一化幅度','FontSize',fontsize_label,'interpreter','tex');
subtitle('\fontname{宋体}未受攻击的\fontname{Times new roman}CIR','FontSize',fontsize_label,'interpreter','tex')

% SFD and PHR check
Rx_respon.PHRsuccessflag = ReceiverPHRRecover(Rx_respon,cfg,length_symbol,50);
Rx_respon.SFDsuccessflag = CheckSFD(Rx_respon);

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