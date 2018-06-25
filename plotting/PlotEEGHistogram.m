function PlotEEGHistogram(eeg, tmin, tmax, sampling_rate, nBins)

whichSamples = (1+tmin*sampling_rate):(1+tmax*sampling_rate); % need "1+" because MATLAB's indexing starts at 1
histogram(eeg(whichSamples),nBins)

end