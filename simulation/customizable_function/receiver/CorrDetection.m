function corres = CorrDetection(field, window, corrlen, cfg)
downsamplenum = cfg.SamplesPerPulse*cfg.PreambleSpreadingFactor;
for n = 1:corrlen
    if(n+(length(window)-1)*downsamplenum > length(field))
        break;
    end
    temp = field(n:downsamplenum:n+(length(window)-1)*downsamplenum);
    corres(n,1) = sum(temp.*window);
    end
end
