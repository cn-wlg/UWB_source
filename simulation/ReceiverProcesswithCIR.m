function Rx = ReceiverProcesswithCIR(cfg,SYNCCIR,SFDCIR,STSCIR,...
    length_SYNC,length_SFD,PAPR,MPEP,corrprewin,Ttx,delaylen)
BTWlen = 200;

% SYNC detection);
[SYNCpeakidx,SYNCmainidx,~] = BTWfindpeak(abs(SYNCCIR), PAPR, MPEP, BTWlen);
SYNCidx = SYNCpeakidx-4;

% SFD detection
[SFDidx,SFDmainidx,~] = BTWfindpeak(abs(SFDCIR), PAPR, MPEP, BTWlen);

% STS detection
[STSidx,STSmainidx,~] = BTWfindpeak(abs(STSCIR), PAPR, MPEP, BTWlen);

Rx.SYNCidxzero = SYNCidx;
Rx.SYNCidx = SYNCidx+(Ttx-1)-corrprewin+delaylen;
Rx.SYNCpeakidx = SYNCpeakidx;
Rx.SYNCmainidx = SYNCmainidx;
Rx.SFDidx = SFDidx-corrprewin+Rx.SYNCidx+length_SYNC*cfg.SamplesPerPulse-1;
Rx.SFDwindowidx = SFDidx-corrprewin;
Rx.SFDmainidx = SFDmainidx-corrprewin;
Rx.STSidx = STSidx-corrprewin+Rx.SYNCidx+(length_SYNC+length_SFD)*cfg.SamplesPerPulse-1;
Rx.STSwindowidx = STSidx-corrprewin;
Rx.STSmainidx = STSmainidx-corrprewin;

end