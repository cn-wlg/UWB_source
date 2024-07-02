function phr = createPHR(cfg)
% As per Sec. 15.2.7 in IEEE Std 802.15.4™‐2020

HPRF = strcmp(cfg.Mode, 'HPRF');

phr = zeros(13, 1);

if ~HPRF
  % 1. Data Rate
  rate = cfg.DataRateNum;
  if rate == 110
    phr(1:2) = [0; 0];
  elseif rate == 850
    phr(1:2) = [0; 1];
  elseif (rate == 6810 && cfg.MeanPRFNum ~= 3.9) || (rate == 1700 && cfg.MeanPRFNum == 3.9)
    phr(1:2) = [1; 0];
  elseif (rate == 27240 && cfg.MeanPRFNum ~= 3.9) || (rate == 6810 && cfg.MeanPRFNum == 3.9)
    phr(1:2) = [1; 1];
  % else error thrown by validateConfig
  end

  % 2. Frame Length
  len = cfg.PSDULength;
  phr(3:9) = de2bi(len, 7)';

  % 3. Ranging
  phr(10) = double(cfg.Ranging);

  % 4. Reserved
  phr(11) = 0;

  % 5. Preamble Duration
  preambleLen = cfg.PreambleDuration;
  if preambleLen == 16
    phr(12:13) = [0; 0];
  elseif preambleLen == 64
    phr(12:13) = [0; 1];
  elseif preambleLen == 1024
    phr(12:13) = [1; 0];
  elseif preambleLen == 4096
    phr(12:13) = [1; 1];
  % else not allowed by lrwpanHRPConfig
  end
  
else % HPRF  
  
  len = cfg.PSDULength;
  if cfg.STSPacketConfiguration==2 && (cfg.ExtraSTSGapIndex>0 || cfg.ExtraSTSGapLength>0)
    phr(1:2) = de2bi(cfg.ExtraSTSGapIndex, 2)';
  else
    phr(1) = bitget(len, 12);  % A1
    phr(2) = bitget(len, 11);  % A0
  end
  
  
  % 2. Payload length
  % call bitget to fetch 10 least significant bits, fliplr for left-msb
  phr(3:12) = fliplr(bitget(len, 1:10));
  
  % 3. Ranging:
  phr(13) = double(cfg.Ranging);
end

% END. Hamming coding - SECDED, i.e., Single error correction, double error detection
phr = hrpSECDED(phr);