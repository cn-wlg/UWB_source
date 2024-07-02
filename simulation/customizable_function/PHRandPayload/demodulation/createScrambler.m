function pnObj = createScrambler(codeIndex, samplesPerFrame, varargin)
%lrwpan.internal.createScrambler Create PN Sequence source as per Sec. 15.3.2 
%  PNOOBJ = lrpwan.internal.createScrambler(CODEINDEX, SAMPLESPERFRAME)
%  creates the comm.PNSequence object PNOBJ as per Sec. 15.3.2 in IEEE Std
%  802.15.4™‐2020. CodeIndex is the index of the used code sequence as per
%  Tables 15-6, 15-7, 15-7a. SamplesPerFrame is the size of the PNOBJ
%  output.
% 
%  PNOOBJ = lrpwan.internal.createScrambler(..., MASKOFFSET) creates a
%  comm.PNSequence object that skips the first MASKOFFSET output samples.

%   Copyright 2021 The MathWorks, Inc.

% As per Sec. 15.3.2 in IEEE Std 802.15.4™‐2020

if nargin == 2
  maskOffset = 0;
else
  maskOffset = varargin{1};
end

pnObj = comm.PNSequence;
% A different notation is used between standard and comm.PNSequence. The
% standard has the extra connection (D^14) close to the register that is
% wrapped around, which is D^1 for comm.PNSequence
pnObj.Polynomial = '1 + D + D15';
code = HRPCodes(codeIndex);
codeHat = postProcessCode(code); % Must remove 0s and replace negatives with 0
pnObj.InitialConditions = fliplr(codeHat); % fliplr because of the difference in convention

pnObj.SamplesPerFrame = samplesPerFrame; % clock every Ncpb. Start with the PHR Ncpb, then change later

pnObj.Mask = 15; % Skip the first 15 (initial conditions), see example in Table 15-10
pnObj.Mask = pnObj.Mask + maskOffset; % skip PHR when starting at payload start

end


function codeHat = postProcessCode(code)
% As per 15.3.2, modify code that is inserted to initial conditions of LFSR

codeHat = code;
% 1. Remove all zeros
codeHat(codeHat==0) = [];
% 2. Replace all -1 with zeros
codeHat(codeHat==-1) = 0;
% 3. Keep the 1st 15
codeHat = codeHat(1:15);
end