% Original
function res = RakeReceive(field, coef, L, len)
[w,t] = sort(coef,'descend');
w = w(1:L);
t = t(1:L);
for i = 1:len
    res(i,1) = sum(conj(w).*field(i+t-1));
end
end

% function res = RakeReceive(field, coef, L, len)
% [coef_peak,peakidx] = findpeaks(abs(coef));
% [w,sortidx] = sort(coef_peak,'descend');
% t = peakidx(sortidx);
% w = w(1:L);
% t = t(1:L);
% for i = 1:len
%     res(i,1) = sum(conj(w).*field(i+t-1));
% end
% end