function [phrEnd, cw, flag] = processPHR(ternarySymbols, phrStart, cfg, validate)
  phrNotPayload = true;
  
  inHPRF = cfg.MeanPRFNum > 62.4;
  if inHPRF
    [cw, phrEnd] = demodHPRF(phrNotPayload, ternarySymbols, phrStart, cfg);
    
  else % BPM-BPSK (Burst-position modulation w BPSK)
   
    [cw, phrEnd] = demodBPMBPSK(phrNotPayload, ternarySymbols, phrStart, cfg);
  end
  % Rate 1/2 coding:
  PHRdemod = convdec(cw(:), cfg.ConstraintLength);
  
  % SECDED decoding -> PHR header
  if validate
    phrLen = 19;
    flag = decodePHR(PHRdemod(1:phrLen), cfg);
  end
end