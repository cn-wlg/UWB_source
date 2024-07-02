function out = hrpRS(in, doEncode)
%lrwpan.internal.hrpRS RS encoding/decoding for HRP PHY
%  OUT = lrpwan.internal.hrpRS(IN, DOENCODE) performs Reed-Solomon encoding
%  or decoding as per Sec. 15.3.3.2 in IEEE Std 802.15.4™‐2020. IN is a
%  binary column vector of any length. DOENCODE is a flag determining if
%  this an encoding or decoding operation, when the flag value is true or
%  false respectively. OUT is the encoded or decoded output when DOENCODE
%  is true or false repectively.

%   Copyright 2021-2022 The MathWorks, Inc.

% As per Sec. 15.3.3.2 in IEEE Std 802.15.4™‐2020

%#codegen

persistent rsEnc rsDec

N = 63;
K = 55;
M = 6;
% genPoly = 'x8 + 55x7 + 61x6 + 37x5 + 48x4 + 47x3 + 20x2 + 6x1 + 22';
% primPoly = '1 + x + x6';
genPoly = rsgenpoly(N,K); 
%primPoly = bi2de([1 0 0 0 0 1 1]); 

out = []; % init output

blockSize = 330;                      % 330 for encoding
if ~doEncode
  blockSize = blockSize + M*(63-55);  % 378 for decoding
end

% Process PSDU in blocks of 330 bits
for blockIdx = 1:ceil(length(in)/blockSize)
  thisBlock = in(1+blockSize*(blockIdx-1) : min(end, blockSize*blockIdx));
  I = length(thisBlock);

  % a) Addition of dummy bits
  inPadded = [zeros(blockSize-I, 1); thisBlock];
  
  % b) Bit-to-symbol conversion, with right-msb
  inPaddedtemp = reshape(inPadded,M,blockSize/M)';
  inPaddedInt = bi2de(inPaddedtemp);
  
  % c) Encoding/Decoding
  if doEncode
    msg = gf(inPaddedInt(1:(blockSize/M))',M);
    tmp = rsenc(msg,N,K,genPoly);  % index to help codegen
  else
    msg = gf(inPaddedInt(1:(blockSize/M))',M);
    tmp = rsdec(msg,N,K,genPoly);
  end
  
  % d) Symbol to bit conversion
  outPaddedBits = double(de2bi(tmp.x', M)');
  outPaddedBits = outPaddedBits(:);
  
  % e) Removal of dummy bits, concatenation with previous outputs
  out = [out; outPaddedBits((1 + max(0, blockSize-I)) :end)]; %#ok<AGROW>
end

