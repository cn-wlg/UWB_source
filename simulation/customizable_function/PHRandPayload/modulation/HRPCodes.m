function code = HRPCodes(codeIndex)
%lrwpan.internal.HRPCodes Get a specific preamble (SYNC) code sequence
%  CODE = lrpwan.internal.HRPCodes(CODEINDEX) returns a specific preamble
%  (SYNC) code sequence indexed by CODEINDEX as per Sec. 15.2.6.2. When
%  CODEINDEX is between 1 and 8, CODE is a 31-symbol sequence as per Table
%  15-6. When CODEINDEX is between 9 and 24, CODE is a 127-symbol sequence
%  as per Table 15-7. When CODEINDEX is between 25 and 32, CODE is a
%  91-symbol sequence as per Table 15-7a.

%   Copyright 2021-2022 The MathWorks, Inc.

%#codegen

persistent Codes

if isempty(Codes)

  Codes = { %% Length 31 - Table 15-6
    [-1 0 0 0 0 +1 0 -1 0 +1 +1 +1 0 +1 -1 0 0 0 +1 -1 +1 +1 +1 0 0 -1 +1 0 -1 0 0]; % 1
    [0 +1 0 +1 -1 0 +1 0 +1 0 0 0 -1 +1 +1 0 -1 +1 -1 -1 -1 0 0 +1 0 0 +1 +1 0 0 0]; % 2
    [-1 +1 0 +1 +1 0 0 0 -1 +1 -1 +1 +1 0 0 +1 +1 0 +1 0 0 -1 0 0 0 0 -1 0 +1 0 -1]; % 3
    [0 0 0 0 +1 -1 0 0 -1 0 0 -1 +1 +1 +1 +1 0 +1 -1 +1 0 0 0 +1 0 -1 0 +1 +1 0 -1]; % 4
    [-1 0 +1 -1 0 0 +1 +1 +1 -1 +1 0 0 0 -1 +1 0 +1 +1 +1 0 -1 0 +1 0 0 0 0 -1 0 0]; % 5
    [+1 +1 0 0 +1 0 0 -1 -1 -1 +1 -1 0 +1 +1 -1 0 0 0 +1 0 +1 0 -1 +1 0 +1 0 0 0 0]; % 6
    [+1 0 0 0 0 +1 -1 0 +1 0 +1 0 0 +1 0 0 0 +1 0 +1 +1 -1 -1 -1 0 -1 +1 0 0 -1 +1]; % 7
    [0 +1 0 0 -1 0 -1 0 +1 +1 0 0 0 0 -1 -1 +1 0 0 -1 +1 0 +1 +1 -1 +1 +1 0 +1 0 0]; % 8
    
    
    %% Length 127 - Table 15-7
    [+1 0 0 +1 0 0 0 -1 0 -1 -1 0 0 -1 -1 +1 0 +1 0 +1 0 0 -1 +1 -1 +1 +1 0 +1 0 0 ...
    0 0 +1 +1 -1 0 0 0 +1 0 0 -1 0 0 -1 -1 0 -1 +1 0 +1 0 -1 -1 0 -1 +1 +1 +1 0 +1 ...
    +1 0 0 0 +1 -1 0 +1 0 0 -1 0 +1 +1 -1 0 +1 +1 +1 0 0 -1 +1 0 0 +1 0 +1 0 -1 0 ...
    +1 +1 -1 +1 -1 -1 +1 0 0 0 0 0 0 +1 0 0 0 0 0 -1 +1 0 0 0 0 -1 0 -1 0 0 0 -1 -1 +1]; %9
    
    [+1 +1 0 0 +1 0 -1 +1 0 0 +1 0 0 +1 0 0 0 0 0 0 -1 0 0 0 -1 0 0 -1 -1 0 0 0 -1 0 +1 ...
    -1 +1 0 -1 0 +1 -1 0 -1 +1 0 0 0 0 0 +1 -1 0 0 +1 +1 0 -1 0 +1 0 0 -1 -1 +1 0 0 +1 ...
    +1 -1 +1 0 +1 -1 0 +1 0 0 0 0 -1 0 -1 0 -1 0 -1 +1 +1 -1 +1 0 +1 0 0 +1 0 +1 0 0 0 ...
    -1 +1 0 +1 +1 +1 0 0 0 -1 -1 -1 -1 +1 +1 +1 0 0 0 0 +1 +1 +1 0 -1 -1];             %10
    
    [-1 +1 -1 0 0 0 0 +1 0 0 -1 -1 0 0 0 0 0 -1 0 +1 0 +1 0 +1 -1 0 +1 0 0 +1 0 0 +1 ...
    0 -1 0 0 -1 +1 +1 +1 0 0 +1 0 0 0 -1 +1 0 +1 0 -1 0 0 0 0 +1 +1 +1 +1 +1 -1 +1 0 ...
    +1 -1 -1 0 +1 -1 0 +1 +1 -1 -1 0 -1 0 0 0 +1 0 -1 +1 0 0 +1 0 +1 -1 -1 -1 -1 0 0 ...
    0 -1 0 0 0 0 0 0 -1 +1 0 0 +1 -1 0 +1 +1 0 0 0 +1 +1 -1 0 0 +1 +1 -1 0 -1 0];      % 11
    
    [-1 +1 0 +1 +1 0 0 0 0 0 0 -1 0 +1 0 -1 +1 0 -1 -1 -1 +1 -1 +1 +1 0 0 -1 +1 0 ...
    +1 +1 0 +1 0 +1 0 +1 0 0 0 -1 0 0 -1 0 0 -1 +1 0 0 +1 -1 +1 +1 0 0 0 -1 +1 -1 0 ...
    -1 +1 +1 0 -1 0 +1 +1 +1 +1 0 -1 0 0 -1 0 +1 +1 0 0 +1 0 +1 0 0 +1 +1 -1 0 0 ...
    +1 0 0 0 +1 -1 0 0 0 -1 0 -1 -1 +1 0 0 0 0 -1 0 0 0 0 -1 -1 0 +1 0 0 0 0 0 +1 -1 -1]; %12
    
    [+1 0 0 0 -1 -1 0 0 0 0 -1 -1 +1 +1 0 -1 +1 +1 +1 +1 0 -1 0 +1 +1 0 +1 0 -1 0 0 ...
    -1 +1 0 +1 +1 0 0 +1 +1 -1 0 +1 +1 0 +1 -1 +1 0 -1 0 0 +1 0 0 -1 0 -1 -1 0 0 0  ...
    -1 +1 -1 0 0 +1 0 0 0 0 -1 0 +1 +1 -1 0 0 0 0 0 +1 -1 0 -1 0 0 0 0 0 0 -1 0 0 -1 ...
    +1 -1 +1 +1 -1 +1 0 0 0 -1 0 +1 0 +1 0 +1 +1 +1 -1 0 0 -1 -1 0 0 +1 0 +1 0 0 0];     %13
    
    [+1 0 0 0 +1 +1 0 -1 0 +1 0 -1 0 0 +1 -1 0 -1 +1 0 -1 0 0 +1 0 +1 0 0 0 0 +1 0 ...
    +1 -1 0 0 0 0 +1 +1 0 0 +1 0 +1 +1 +1 +1 +1 -1 +1 0 -1 0 +1 -1 0 -1 -1 +1 0 +1 ...
    +1 -1 -1 0 0 0 -1 -1 -1 0 +1 0 0 0 +1 0 +1 0 -1 +1 -1 0 0 0 0 0 0 +1 -1 +1 -1 ...
    0 -1 -1 0 0 +1 +1 0 0 0 -1 0 0 +1 0 0 +1 +1 -1 0 0 -1 -1 +1 +1 -1 0 0 -1 0 0 0 0 0]; %14
    
    [0 +1 -1 0 0 +1 0 -1 0 0 0 -1 +1 +1 0 0 0 0 -1 -1 -1 +1 +1 0 0 0 +1 0 +1 -1 0 -1 ...
    +1 0 0 -1 +1 0 0 0 -1 -1 0 -1 0 0 -1 -1 0 -1 -1 +1 +1 +1 -1 +1 0 -1 +1 +1 0 0 +1 ...
    -1 +1 +1 0 +1 0 0 0 0 0 +1 0 -1 0 +1 +1 +1 -1 0 0 +1 0 0 +1 0 0 0 -1 0 0 0 0 +1 ...
    0 0 -1 -1 +1 0 +1 +1 0 +1 0 +1 0 -1 0 0 -1 0 -1 +1 -1 0 +1 0 +1 +1 0 0 0 0 0];     % 15
    
    [+1 +1 0 0 0 0 +1 0 0 0 +1 0 0 +1 -1 -1 0 +1 -1 +1 +1 0 -1 0 0 0 -1 -1 0 0 +1 -1 ...
    0 +1 0 0 +1 +1 0 0 0 +1 +1 +1 0 0 +1 0 +1 0 -1 0 -1 +1 -1 0 -1 0 +1 0 0 +1 0 0 +1 ...
    0 +1 +1 -1 -1 -1 -1 +1 0 0 +1 +1 -1 -1 +1 0 +1 -1 0 -1 -1 +1 0 0 0 0 0 0 -1 0 -1 ...
    0 0 0 0 -1 +1 0 -1 -1 0 0 +1 0 0 0 0 0 +1 -1 +1 +1 0 0 0 -1 0 -1 +1 0 +1 0];       % 16
    
    [+1 -1 -1 0 0 0 -1 0 -1 0 0 0 0 +1 -1 0 0 0 0 0 +1 0 0 0 0 0 0 +1 -1 -1 +1 -1 +1 ...
    +1 0 -1 0 +1 0 +1 0 0 +1 -1 0 0 +1 +1 +1 0 -1 +1 +1 0 -1 0 0 +1 0 -1 +1 0 0 0 +1 ...
    +1 0 +1 +1 +1 -1 0 -1 -1 0 +1 0 +1 -1 0 -1 -1 0 0 -1 0 0 +1 0 0 0 -1 +1 +1 0 0 0 ...
    0 +1 0 +1 +1 -1 +1 -1 0 0 +1 0 +1 0 +1 -1 -1 0 0 -1 -1 0 -1 0 0 0 +1 0 0 +1];      % 17
    
    [-1 -1 0 +1 +1 +1 0 0 0 0 +1 +1 +1 -1 -1 -1 -1 0 0 0 +1 +1 +1 0 +1 -1 0 0 0 +1 ...
    0 +1 0 0 +1 0 +1 -1 +1 +1 -1 0 -1 0 -1 0 -1 0 0 0 0 +1 0 -1 +1 0 +1 -1 +1 +1 0 ...
    0 +1 -1 -1 0 0 +1 0 -1 0 +1 +1 0 0 -1 +1 0 0 0 0 0 +1 -1 0 -1 +1 0 -1 0 +1 -1 +1 ...
    0 -1 0 0 0 -1 -1 0 0 -1 0 0 0 -1 0 0 0 0 0 0 +1 0 0 +1 0 0 +1 -1 0 +1 0 0 +1 +1];   % 18
    
    [-1 0 -1 +1 +1 0 0 -1 +1 +1 0 0 0 +1 +1 0 -1 +1 0 0 +1 -1 0 0 0 0 0 0 -1 0 0 0 ...
    -1 -1 -1 -1 +1 0 +1 0 0 +1 -1 0 +1 0 0 0 -1 0 -1 -1 +1 +1 0 -1 +1 0 -1 -1 +1 0 ...
    +1 -1 +1 +1 +1 +1 +1 0 0 0 0 -1 0 +1 0 +1 -1 0 0 0 +1 0 0 +1 +1 +1 -1 0 0 -1 ...
    0 +1 0 0 +1 0 0 +1 0 -1 +1 0 +1 0 +1 0 -1 0 0 0 0 0 -1 -1 0 0 +1 0 0 0 0 -1 +1 -1 0]; % 19
    
    [-1 -1 +1 0 0 0 0 0 +1 0 -1 -1 0 0 0 0 -1 0 0 0 0 +1 -1 -1 0 -1 0 0 0 -1 +1 0 0 0 ...
    +1 0 0 -1 +1 +1 0 0 +1 0 +1 0 0 +1 +1 0 -1 0 0 -1 0 +1 +1 +1 +1 0 -1 0 +1 +1 -1 0 ...
    -1 +1 -1 0 0 0 +1 +1 -1 +1 0 0 +1 -1 0 0 -1 0 0 -1 0 0 0 +1 0 +1 0 +1 0 +1 +1 0 +1 ...
    -1 0 0 +1 +1 -1 +1 -1 -1 -1 0 +1 -1 0 +1 0 -1 0 0 0 0 0 0 +1 +1 0 +1 -1];             % 20
    
    [+1 0 +1 0 0 -1 -1 0 0 -1 +1 +1 +1 0 +1 0 +1 0 -1 0 0 0 +1 -1 +1 +1 -1 +1 -1 0 0 ...
    -1 0 0 0 0 0 0 -1 0 -1 +1 0 0 0 0 0 -1 +1 +1 0 -1 0 0 0 0 +1 0 0 -1 +1 -1 0 0 0 ...
    -1 -1 0 -1 0 0 +1 0 0 -1 0 +1 -1 +1 0 +1 +1 0 -1 +1 +1 0 0 +1 +1 0 +1 -1 0 0 -1 ...
    0 +1 0 +1 +1 0 -1 0 +1 +1 +1 +1 -1 0 +1 +1 -1 -1 0 0 0 0 -1 -1 0 0 0 +1 0 0 0];       % 21
    
    [0 -1 0 0 -1 +1 +1 -1 -1 0 0 -1 +1 +1 0 0 +1 0 0 -1 0 0 0 +1 +1 0 0 -1 -1 0 -1 +1 ...
    -1 +1 0 0 0 0 0 0 -1 +1 -1 0 +1 0 +1 0 0 0 +1 0 -1 -1 -1 0 0 0 -1 -1 +1 +1 0 +1 -1 ...
    -1 0 -1 +1 0 -1 0 +1 -1 +1 +1 +1 +1 +1 0 +1 0 0 +1 +1 0 0 0 0 -1 +1 0 +1 0 0 0 0 +1 ...
    0 +1 0 0 -1 0 +1 -1 0 -1 +1 0 0 -1 0 +1 0 -1 0 +1 +1 0 0 0 +1 0 0 0 0];               % 22
    
    [0 0 0 +1 +1 0 +1 0 -1 +1 -1 0 -1 0 0 -1 0 +1 0 +1 0 +1 +1 0 +1 -1 -1 0 0 +1 0 0 0 ...
    0 -1 0 0 0 +1 0 0 +1 0 0 -1 +1 +1 +1 0 -1 0 +1 0 0 0 0 0 +1 0 +1 +1 -1 +1 0 0 +1 +1 ...
    -1 0 +1 -1 +1 +1 +1 -1 -1 0 -1 -1 0 0 -1 0 -1 -1 0 0 0 +1 -1 0 0 +1 -1 0 -1 +1 0 +1 ...
    0 0 0 +1 +1 -1 -1 -1 0 0 0 0 +1 +1 -1 0 0 0 -1 0 +1 0 0 -1 +1 0 0 0];                 % 23
    
    [+1 0 +1 -1 0 -1 0 0 0 +1 +1 -1 +1 0 0 0 0 0 +1 0 0 -1 -1 0 +1 -1 0 0 0 0 -1 0 -1 0 ...
    0 0 0 0 0 +1 -1 -1 0 -1 +1 0 +1 -1 -1 +1 +1 0 0 +1 -1 -1 -1 -1 +1 +1 0 +1 0 0 +1 0 0 ...
    +1 0 -1 0 -1 +1 -1 0 -1 0 +1 0 +1 0 0 +1 +1 +1 0 0 0 +1 +1 0 0 +1 0 -1 +1 0 0 -1 -1 ...
    0 0 0 -1 0 +1 +1 -1 +1 0 -1 -1 +1 0 0 +1 0 0 0 +1 0 0 0 0 +1 +1 0];                   % 24
    
    
    %% Length 91 - Table 15-7a
    [-1 0 +1 +1 +1 +1 -1 -1 +1 -1 -1 +1 -1 +1 +1 +1 +1 -1 +1 -1 -1 -1 +1 +1 -1 -1 +1 +1 ...
    +1 +1 +1 +1 -1 +1 +1 -1 +1 0 0 +1 -1 -1 +1 0 -1 -1 +1 0 +1 +1 +1 +1 +1 -1 -1 +1 ...
    +1 +1 -1 -1 0 -1 -1 0 +1 -1 +1 -1 -1 -1 -1 0 -1 +1 -1 +1 -1 +1 0 +1 -1 -1 +1 +1 -1 +1 ...
    -1 +1 +1 +1 0]; % 25
    
    [+1 +1 0 +1 -1 +1 -1 -1 -1 +1 +1 +1 +1 +1 -1 +1 -1 +1 +1 -1 -1 +1 -1 -1 +1 +1 -1 -1 -1 ...
    +1 -1 0 +1 +1 +1 0 -1 +1 +1 +1 +1 -1 +1 0 +1 0 -1 -1 0 +1 -1 +1 +1 -1 +1 +1 +1 +1 +1 +1 ...
    -1 -1 +1 -1 +1 +1 0 0 +1 +1 +1 -1 -1 0 +1 -1 -1 -1 -1 -1 +1 -1 0 +1 -1 +1 -1 +1 -1 -1 -1]; % 26
    
    [+1 +1 +1 -1 -1 +1 +1 +1 -1 -1 -1 +1 -1 +1 -1 0 -1 +1 -1 -1 0 +1 +1 -1 +1 -1 +1 0 -1 +1 ...
    +1 +1 +1 +1 +1 +1 +1 +1 +1 -1 -1 +1 -1 -1 +1 +1 -1 +1 +1 0 +1 +1 -1 +1 -1 +1 -1 -1 +1  ...
    -1 -1 +1 +1 +1 -1 -1 -1 0 -1 +1 +1 +1 -1 0 +1 0 0 -1 -1 -1 +1 +1 -1 +1 -1 -1 0 -1 +1 +1 0]; % 27
    
    [+1 +1 +1 +1 +1 -1 -1 +1 +1 +1 -1 +1 +1 -1 -1 -1 +1 -1 +1 -1 -1 0 +1 +1 -1 -1 -1 +1 -1 +1 0 ...
    +1 -1 -1 -1 -1 -1 +1 0 +1 +1 +1 -1 -1 +1 -1 +1 -1 -1 +1 -1 +1 +1 -1 +1 +1 +1 +1 0 -1 0 -1 +1 ...
    +1 0 0 +1 -1 +1 +1 +1 -1 +1 +1 -1 +1 0 -1 +1 0 -1 -1 +1 -1 -1 -1 +1 +1 +1 0 +1]; % 28
    
    [+1 -1 0 -1 -1 +1 -1 +1 +1 -1 -1 0 +1 +1 0 0 +1 +1 -1 +1 +1 -1 -1 -1 -1 -1 +1 +1 +1 +1 ...
    +1 +1 -1 0 +1 -1 -1 +1 -1 +1 +1 -1 -1 +1 -1 +1 +1 +1 -1 -1 +1 +1 +1 +1 +1 +1 +1 -1 +1 +1 ...
    +1 0 +1 -1 +1 -1 0 -1 0 -1 +1 +1 -1 -1 -1 +1 0 -1 -1 -1 +1 +1 0 -1 +1 -1 +1 -1 +1 +1 -1]; % 29
    
    [-1 +1 +1 0 -1 -1 0 +1 +1 -1 0 0 -1 -1 +1 +1 -1 +1 +1 -1 +1 -1 -1 +1 +1 +1 +1 +1 -1 -1 ...
    -1 +1 +1 +1 -1 +1 -1 0 +1 -1 +1 -1 +1 0 +1 +1 +1 +1 +1 -1 +1 +1 +1 -1 +1 +1 +1 -1 +1 0 ...
    -1 -1 -1 -1 -1 -1 +1 +1 -1 +1 +1 -1 +1 0 -1 -1 -1 -1 +1 -1 +1 -1 0 +1 0 +1 -1 +1 +1 +1 -1]; % 30
    
    [-1 +1 -1 +1 +1 0 +1 +1 +1 -1 -1 +1 +1 -1 0 +1 +1 0 0 -1 -1 +1 +1 -1 -1 +1 +1 +1 -1 +1 ...
    -1 -1 -1 -1 -1 -1 0 +1 +1 +1 -1 +1 +1 +1 +1 +1 -1 -1 +1 -1 +1 +1 -1 -1 -1 +1 -1 +1 -1 ...
    -1 -1 +1 -1 +1 0 -1 +1 -1 -1 0 +1 0 +1 -1 +1 +1 -1 +1 +1 0 +1 -1 +1 -1 -1 0 +1 +1 +1 +1 +1]; % 31
    
    [-1 +1 +1 +1 +1 +1 +1 +1 +1 +1 +1 +1 -1 -1 -1 +1 -1 +1 +1 -1 -1 +1 +1 0 0 -1 +1 -1 +1 0 ...
    -1 +1 -1 0 -1 +1 +1 -1 -1 +1 +1 +1 -1 +1 +1 +1 0 -1 -1 0 +1 +1 -1 +1 -1 +1 -1 0 -1 -1 -1 ...
    +1 +1 -1 0 -1 -1 -1 -1 +1 +1 +1 +1 -1 +1 -1 0 +1 0 -1 +1 -1 +1 +1 -1 +1 +1 -1 -1 +1 -1]; % 32
    };
end

code = Codes{codeIndex};

