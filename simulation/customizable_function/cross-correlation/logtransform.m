function out = logtransform(in, thr)
    out = 10*log10(in);
    out(out<thr) = thr;
end