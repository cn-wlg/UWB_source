function [PHRflag,phrEnd, phrCW,ternarySymbols] = ReceiverPHRRecover(Rx,cfg,length_symbols,Rakenum)
% PHYfield = wave_rx_ATK(SYNCidx+(length(SHR)+length(STS))*cfgHPRF.SamplesPerPulse-200:end);
CIR_STSest = Rx.STScorres;
PHYfield = Rx.wave_rx_match;
Rakeres = RakeReceive(PHYfield, CIR_STSest, Rakenum, length_symbols*cfg.SamplesPerPulse);
PHYwave = Rakeres;

% Integrate and dump: Convert waveform to ternary (-1, 0, 1) symbols
integOffset = 1+round(cfg.SamplesPerPulse/2); % Group delay is equal to SamplesPerPulse.
integrated = intdump([real(PHYwave(1+integOffset:end)); ...
    zeros(ceil(length(PHYwave)/cfg.SamplesPerPulse)*cfg.SamplesPerPulse-length(PHYwave(1+integOffset:end)), 1)],...
    cfg.SamplesPerPulse) * cfg.SamplesPerPulse;
ternarySymbols = integrated;
T = max(ternarySymbols)*0.25;
ternarySymbols(abs(ternarySymbols)<T) = 0;
ternarySymbols(ternarySymbols>T) = 1;
ternarySymbols(ternarySymbols<-T) = -1;

% PHY decode
[phrEnd, phrCW, PHRflag] = processPHR(ternarySymbols, 1, cfg, true);

end