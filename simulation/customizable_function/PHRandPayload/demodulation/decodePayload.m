function [PSDU, payloadEnd] = decodePayload(ternarySymbols, payloadStart, cwPHR, cfg)
  phrNotPayload = false;
  
  PSDULength = cfg.PSDULength*8;
  if cfg.MeanPRFNum < 124.8 || cfg.ConstraintLength == 3
    % PSDU Length describe the number of uncoded octets. ternarySymbols
    % contain PSDU that may be RS-encoded
    N = 63;
    K = 55;
    blockSize = 330;
    % parity bits are added for any block of 333 bits, even if partially filled
    PSDULength = PSDULength + ((N-K)*blockSize/K) * ceil(PSDULength/blockSize);
  end
  
  % "Modulation symbols" to codewords
  inHPRF = cfg.MeanPRFNum > 62.4;
  if inHPRF
    [cwPayload, payloadEnd] = demodHPRF(phrNotPayload, ternarySymbols, payloadStart, cfg, PSDULength);
    
  else % BPM-BPSK (Burst-position modulation w BPSK)
   
    [cwPayload, payloadEnd] = demodBPMBPSK(phrNotPayload, ternarySymbols, payloadStart, cfg, PSDULength);
  end
  
  % Rate 1/2 convolutional coding:
  if cfg.ConvolutionalCoding
    cw = [cwPHR cwPayload];
    decoded = convdec(cw(:), cfg.ConstraintLength);
    
    numPHRSymbols = 19;
    if cfg.MeanPRFNum < 124.8 || cfg.ConstraintLength == 3
      tailToIgnore = 2;
      rsCW = decoded(1+numPHRSymbols: end-tailToIgnore);
    
    else % CL = 7
      % Sec. 15.3.3.3 in 15.4z: "separately appending six zero bits to both the PHR and the PSDU"
      tailToIgnore = 6;
      % tail after payload is ignored during modulation
      rsCW = decoded(1+numPHRSymbols+tailToIgnore: end);
    end
    
  else % No Convolutional Coding
    rsCW = cwPayload;
  end
  
  % Reed Solomon decoding -> PSDU
  if cfg.MeanPRFNum < 124.8 || cfg.ConstraintLength == 3
    encodeNotDecode = false;
    PSDU = hrpRS(rsCW, encodeNotDecode);
  else
    % no RS encoding when HPRF and constraint length = 7
    PSDU = rsCW;
  end
end