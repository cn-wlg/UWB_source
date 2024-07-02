function Rx = ReceiverProcess(wave_rx,...
    cfg,length_SYNC,length_SFD,length_STS,SYNCwindow,SFDwindow,STSwindow,corrlen,PAPR,MPEP,...
    STSzerolen,corrprewin,firstzeros,Ttx)
BTWlen = 200;

% match filter
wave_rx_match = butterworthmatchFilter(wave_rx, cfg.SamplesPerPulse);
wave_rx_match = wave_rx_match(firstzeros+1:end);

% SYNC detection
SYNCcorrlen = corrlen;
SYNCcorres = CorrDetection(wave_rx_match, SYNCwindow, SYNCcorrlen, cfg);
[SYNCpeakidx,SYNCmainidx,SYNCBTW] = BTWfindpeak(abs(SYNCcorres), PAPR, MPEP, BTWlen);
SYNCidx = SYNCpeakidx-4;

% SFD detection
SFDfield = wave_rx_match(SYNCpeakidx+length_SYNC*cfg.SamplesPerPulse-corrprewin:end);
SFDcorrlen = corrlen;
SFDcorres = CorrDetection(SFDfield, SFDwindow, SFDcorrlen, cfg);
[SFDidx,SFDmainidx] = BTWfindpeak(abs(SFDcorres), PAPR, MPEP, BTWlen);

% STS detection
STSfield = wave_rx_match(SYNCpeakidx+(length_SYNC+length_SFD)*cfg.SamplesPerPulse+STSzerolen-corrprewin:end);
STScorrlen = corrlen;
STScorres = STSCorrDetection(STSfield, STSwindow, STScorrlen, cfg);
[STSidx,STSmainidx,STSBTW] = BTWfindpeak(abs(STScorres), PAPR, MPEP, BTWlen);

Rx.SYNCidx = SYNCidx+(Ttx-1);
Rx.SYNCpeakidx = SYNCpeakidx;
Rx.SYNCmainidx = SYNCmainidx;
Rx.SYNCcorres = SYNCcorres;
Rx.SFDidx = SFDidx-corrprewin+Rx.SYNCidx+length_SYNC*cfg.SamplesPerPulse-1;
Rx.SFDwindowidx = SFDidx-corrprewin;
Rx.SFDmainidx = SFDmainidx-corrprewin;
Rx.SFDcorres = SFDcorres;
Rx.STSidx = STSidx-corrprewin+Rx.SYNCidx+(length_SYNC+length_SFD)*cfg.SamplesPerPulse-1;
Rx.STSwindowidx = STSidx-corrprewin;
Rx.STSmainidx = STSmainidx-corrprewin;
Rx.STScorres = STScorres;
Rx.wave_rx_match = wave_rx_match(SYNCidx+(length_SYNC+length_SFD+length_STS)*cfg.SamplesPerPulse-corrprewin:end);
% Rx.STSBTW = STSBTW;
% Rx.SYNCBTW = SYNCBTW;

end