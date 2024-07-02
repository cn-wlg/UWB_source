% function res = RakeReceive(field, coef, L, len)
% for i = 1:len
%     res(i,1) = sum(conj(coef(1:L)).*field(i:i+L-1));
% end
% end