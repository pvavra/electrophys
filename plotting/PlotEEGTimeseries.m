function ax = PlotEEGTimeseries(eeg, tmin, tmax, sampling_rate,plot_line_spec )

% set default LineSpec for plot
if nargin <= 4
    plot_line_spec = '.-'; 
end

t = tmin:1/sampling_rate:tmax; % define time axis

whichSamples = (1+round(tmin*sampling_rate)):(1+round(tmax*sampling_rate)); % need "1+" because MATLAB's indexing starts at 1
plot(t,eeg(whichSamples),plot_line_spec)
xlim([tmin tmax])
ax = gca;
end