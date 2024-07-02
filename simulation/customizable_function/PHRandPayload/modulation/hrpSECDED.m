function PHR = hrpSECDED(PHR)
%HRPSECDED Add parity 6 bits to 13-bit PHR, enabling single error
%correction, double error detection

%   Copyright 2021-2022 The MathWorks, Inc

% As per Sec. 15.2.7 in IEEE Std 802.15.4™‐2020

%#codegen

PHR = [PHR; zeros(6, 1)];

PHR(19) = mod(sum(PHR([2, 1, 9, 7, 5, 4, 11, 12])), 2);
PHR(18) = mod(sum(PHR([1, 7, 6, 4, 3, 10, 11, 13])), 2);
PHR(17) = mod(sum(PHR([2, 9, 8, 4, 3, 10, 11])), 2);
PHR(16) = mod(sum(PHR([9, 8, 7, 6, 5, 10, 11])), 2);
PHR(15) = mod(sum(PHR([13 12])), 2);
PHR(14) = mod(sum(PHR), 2);

end