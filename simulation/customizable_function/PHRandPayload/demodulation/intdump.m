function y = intdump(x, Nsamp)
%INTDUMP Integrate and dump.
%   Y = INTDUMP(X, NSAMP) integrates the signal X for 1 symbol period, then
%   outputs the averaged one value into Y. NSAMP is the number of samples
%   per symbol. For two-dimensional signals, the function treats each
%   column as 1 channel.
%
%   See also RECTPULSE.

%    Copyright 1996-2011 The MathWorks, Inc.


% --- Assure that X, if one dimensional, has the correct orientation --- %
wid = size(x,1);
if(wid ==1)
    x = x(:);
end


[xRow, xCol] = size(x);

x = mean(reshape(x, Nsamp, xRow*xCol/Nsamp), 1);
y = reshape(x, xRow/Nsamp, xCol);      

% --- restore the output signal to the original orientation --- %
if(wid == 1)
    y = y.';
end