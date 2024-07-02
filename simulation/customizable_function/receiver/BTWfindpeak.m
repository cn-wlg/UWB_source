function [startinx, maxinx, BTW, PAPRnum, MPEPnum, firstpeak] = BTWfindpeak(corr, PAPR, MPEP, BTWlen)

[maxpeak,maxinx] = max(corr);
maxpeak = maxpeak(1);
maxinx = maxinx(1);

meanpower = mean(corr);
PAPRnum = meanpower*PAPR;
MPEPnum = maxpeak*MPEP;

if(maxpeak < meanpower*PAPR)
    startinx = [];
    BTW = [];
    firstpeak = maxpeak;
    return;
end
if(maxinx-BTWlen+1>=1)
    BTW = corr(maxinx-BTWlen+1:maxinx); % back time window
else
    BTW = corr(1:maxinx); % back time window
end
if(length(BTW)<3)
    startinx = length(BTW);
    BTW = [];
    return
end    
[S_peak,S_inx] = findpeaks(BTW);
S_peak = [S_peak;maxpeak];
S_inx = [S_inx;length(BTW)];
startinx = find(S_peak>maxpeak*MPEP & S_peak>meanpower*PAPR);
if(isempty(startinx))
    return;
end
startinx = S_inx(startinx);
firstpeak = BTW(startinx(1));
startinx = startinx(1)+maxinx-length(BTW);

end