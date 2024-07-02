function [wave,SYNCbit,SFDbit,STSbit,SYNC,SFD,STS,power_SHR,power_STS,length_symbol] = UWBwaveGEN(cfg,PSDU,STSmode)
% SHR and STS generation
[SHR, SYNC, SFD, SYNCbit, SFDbit] = createSHR(cfg);
% [STS,STSbit] = createSTS(cfg,0);
[STS,STSbit] = createSTS(cfg,STSmode);
% PHR generation
PHR = createPHR(cfg);
% Convolutional Encoding
convolCW = convolEnc(PHR, PSDU, cfg);
% Symbol Mapper (Modulation)
symbols = symbolMapper(convolCW, cfg);

% wave generaiton
wave1 = butterworthFilter(SHR, cfg.SamplesPerPulse);
wave2 = butterworthFilter(STS, cfg.SamplesPerPulse);
wave3 = butterworthFilter(symbols, cfg.SamplesPerPulse);
wave = [wave1;wave2;wave3];
power_SHR = powercal(wave1);
power_STS = powercal(wave2);
length_symbol = length(symbols);
end