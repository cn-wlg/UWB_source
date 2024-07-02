function symbolMap = hrpHPRFSymbolMap(meanPRFNum, constraintLength)
%lrwpan.internal.hrpHPRFSymbolMap Get (PHR and Payload) codeword to symbol mapping
%  SYMBOLMAP = lrpwan.internal.hrpHPRFSymbolMap(MEANPRFNUM, CONSTRAINTLENGTH)
%  returns the PHR or payload modulation symbols as in Sec. 15.3 of IEEE
%  Std 802.15.4z™‐2020. MEANPRFNUM is either the 249.6 or the 124.8 numeric
%  value; it determines the modulation type and the symbol length.
%  CONSTRAINTLENGTH is either 3 or 7 and is the constraint length of the
%  convolutional encoder. SYMBOLMAP is a matrix, containing one row for
%  each symbol; symbols are indexed by converting the input codeword ([g0
%  g1]) to a decimal number (right-msb).

%   Copyright 2021-2022 The MathWorks, Inc.

%#codegen 

len = 4*249.6/meanPRFNum;
if constraintLength == 3
  % As per Table 15.10c/e in IEEE Std 802.15.4z™‐2020
  symbolMap = [ zeros(1, len)  zeros(1, len)   zeros(1, len)   zeros(1, len);
                ones(1, len)   zeros(1, len)   ones(1, len)    zeros(1, len);
                ones(1, len)   ones(1, len)    ones(1, len)    ones(1, len);
                zeros(1, len)  ones(1, len)    zeros(1, len)   ones(1, len)];
else % CL = 7
  % As per Table 15.10d/f in IEEE Std 802.15.4z™‐2020
  symbolMap = [ zeros(1, len)  zeros(1, len);
                ones(1, len)   zeros(1, len);
                zeros(1, len)  ones(1, len);
                ones(1, len)   ones(1, len)];
end
end