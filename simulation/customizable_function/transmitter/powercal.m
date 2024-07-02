function power = powercal(x)
    power = sum(abs(x).^2)/length(x);
end