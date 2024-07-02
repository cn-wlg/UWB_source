function plotwindow = plotCorr(corres,plotlen)
[~,peakidx] = max(corres);
plotwindow = abs(corres(peakidx-plotlen:peakidx+plotlen));
plotwindow = plotwindow/max(plotwindow);
end