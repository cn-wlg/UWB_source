function flag = decodePHR(demodPHR, cfg)

% SECDED decoding 
% The parity bit XOR formula can construct a binary index address pointing
% to the location of the error in the systematic bits.
% Addressing is constructed after removing powers of two from possible indexes: 
% [b0 b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12]
%   3  5  6  7  9 10 11 12 13 14  15  17  18
  flag = true;
  receivedSystematic = demodPHR(1:13);
  receivedParity = demodPHR(14:end);
  phr = hrpSECDED(receivedSystematic);
  syndromes = xor(receivedParity, phr(14:end));
  
  idx = bi2de(flipud(syndromes(2:end))'); 
  
  if idx > 0 % error can be corrected
    powersOf2 = 2.^(0:5);
    addresses = setdiff(1:length(demodPHR), powersOf2);
    errorLocation = find(addresses==idx);
    phr(errorLocation) = ~phr(errorLocation);
  end
  
  inHPRF = cfg.MeanPRFNum > 62.4;
  if inHPRF
    if cfg.STSPacketConfiguration == 2 && (cfg.ExtraSTSGapLength > 0 || cfg.ExtraSTSGapIndex > 0) 
      extraGapIdx = de2bi(phr(1:2)');
      PSDULength = de2bi(phr(3:12)');
    else
      PSDULength = de2bi(phr(1:12)');
    end
    ranging = logical(phr(13));
  else
    if cfg.MeanPRFNum == 3.9
      dataRates = [0.11 0.85 1.7 6.81];
    else
      dataRates = [0.11 0.85 6.81 27.24];
    end
    dataRate = dataRates(1+bi2de(flipud(phr(1:2))', 2));
    if dataRate*1e3 ~= cfg.DataRateNum
      flag = false;
    end
    
    PSDULength = bi2de(phr(3:9)'); %#ok<*NASGU> 
    
    ranging = logical(phr(10));
    
    if(cfg.PreambleDuration == 16 || cfg.PreambleDuration == 64 ||...
            cfg.PreambleDuration == 1024 || cfg.PreambleDuration == 4096)
        preambleDurations = [16 64 1024 4096];
        preambleDuration = preambleDurations(1+bi2de(flipud(phr(12:13))'));
        if preambleDuration ~= cfg.PreambleDuration
          flag = false;
        end
    end
  end
  if PSDULength ~= cfg.PSDULength
    flag = false;
  end
   
  if ranging ~= cfg.Ranging
    flag = false;
  end
end
  