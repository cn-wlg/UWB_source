function wave = butterworthmatchFilter(symbols, spc)

N = 4;
Fc = 500e6;
Fs = Fc*spc;
[b,a] = butter(N, Fc/Fs);

impulse = impz(b,a,16);
% wave = conv(flipud(impulse), symbols);
% startidx = length(impulse)/2;
% endidx = length(impulse)/2; 
% wave = wave(startidx:end-endidx);

wave = filter(flipud(impulse), 1, symbols);
wave = wave(12:end);
end