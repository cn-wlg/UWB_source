function sidepeak = findsidepeak(corr)
    corr = abs(corr);
    [peaks, ~] = findpeaks(corr);
    peaks_sort = sort(peaks,'descend');
    sidepeak = peaks_sort(2);
end