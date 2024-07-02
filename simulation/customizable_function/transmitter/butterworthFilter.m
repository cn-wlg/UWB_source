function wave = butterworthFilter(symbols, spc)

N = 4;
Fc = 500e6;
Fs = Fc*spc;
[b,a] = butter(N, Fc/Fs);

impulse = impz(b,a,16);

symbols_spread = zeros(length(symbols)*spc,1);
symbols_spread(1:spc:end) = symbols;

% wave1 = conv(flipud(impulse), symbols_spread);
% startidx = length(impulse)/2;
% endidx = length(impulse)/2; 
% wave1 = wave1(startidx:end-endidx);

wave = filter(impulse, 1, symbols_spread);
% subplot(211);plot(wave1(1:100))
% subplot(212);plot(wave(1:100))
wave = wave/max(wave);

end