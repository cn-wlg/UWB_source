function corres = STSCorrDetection(field, window, corrlen, cfg)
if strcmp(cfg.Mode, 'BPRF') % BPRF
  downsamplenum = cfg.SamplesPerPulse*4;
else % HPRF
  downsamplenum = cfg.SamplesPerPulse*4;
end
for n = 1:corrlen
    if(n+(length(window)-1)*downsamplenum > length(field))
        break;
    end
    temp = field(n:downsamplenum:n+(length(window)-1)*downsamplenum);
    corres(n,1) = sum(temp.*window);
    end
end
