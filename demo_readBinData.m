addpath('axona_io')

%% load data
% dataFilename = '/data/fred/Dataset Mouse 304/Raw/304D1TFC.bin'; % 9GB
dataFilename = '/data/fred_old/pilot_data/1556.bin'; % <1GB

[data_matrix, fileStats, packets_matrix] = read_bin_file(dataFilename);


%% get all non-empty channels
tic
% for some reason, even unconnected channels have non-zero data for the
% first couple of samples
emptyChannels = all(data_matrix(:,10:end) == 0,2); 
toc

usedChannels = 1:64; usedChannels = usedChannels(~emptyChannels);

%% downsample and subset data for inspection
% try to avoid 'freezing' figures (due too many datapoints)
Fs = 48000;
downsamplingFactor = 192; % will give 250Hz

tmin = 0; % in seconds
tmax = 10; % in seconds
indicesSubset = (tmin*Fs:tmax*Fs) +1; %

tic
% result is now matching usedChannels
result = downsample(data_matrix(usedChannels,indicesSubset)', downsamplingFactor )'; 
toc

time = tmin:downsamplingFactor/Fs:tmax;

%% plot basic info
figure(100);
clf
imagesc(...
    [time(1) time(end)],[1 size(result,1)],... % define edges
    result...
    )
ylabel('channels')
xlabel('time [s]')
yticks(1:size(result,1))
yticklabels(num2str(usedChannels'))
title(sprintf('timeseries of all used channels (subset for time from %g to %g seconds)',tmin, tmax))

%% plot each channel individually
for iChannel = 1%:length(usedChannels)
    figure(iChannel);
    
    channel = usedChannels(iChannel);
    
    subplot(311)
    hold off
    plot(time,result(iChannel,:))
    hold on
    ylim([-2^15 2^15])
    title(sprintf('timeseries of x(%i,:)',channel))
    
    subplot(312)
    histogram(result(iChannel,:),-2^15:2^10:2^15)
    xlim([-2^15 2^15])
    title(sprintf('histogram of x(%i,:)',channel))
    
    subplot(313)
    L = size(result,2);
    frequencies = Fs/downsamplingFactor * (0:(L/2))/L;
    spectrum = PowerSpectrum(result(iChannel,:));
    freq_boundaries = [0 20];
    indices_selection = frequencies > freq_boundaries(1) & frequencies < freq_boundaries(2);
    plot(frequencies(indices_selection), spectrum(indices_selection))
    title('Power Spectrum');
    xlabel('Frequency [Hz]')
    ylabel('Power')
    
end

%% referencing

tic
referenced = ReferenceData(result, 1); % use first usedChannel as reference electrode
toc

%% plot basic info
figure(101);
clf
imagesc(...
    [time(1) time(end)],[1 size(result,1)],... % define edges
    referenced...
    )
ylabel('channels')
xlabel('time [s]')
yticks(1:size(result,1))
yticklabels(num2str(usedChannels'))
title(sprintf('referenced to first used channel (ie. %g)',usedChannels(1)))


%% mean referencing

tic
[referenced, refSignal] = ReferenceData(result, 1:16); % use first 16 channels (i.e. where there is data)
toc

%% plot basic info
figure(102);
clf
imagesc(...
    [time(1) time(end)],[1 size(result,1)],... % define edges
    referenced...
    )
ylabel('channels')
xlabel('time [s]')
yticks(1:size(result,1))
yticklabels(num2str(usedChannels'))
title(sprintf('mean-referenced to first 16 channels'))


%% plot each channel individually
for iChannel = 1%:length(usedChannels)
    figure(iChannel);
    
    channel = usedChannels(iChannel);
    
    subplot(311)
    hold off
    plot(time,result(iChannel,:))
    hold on
    ylim([-2^15 2^15])
    title(sprintf('timeseries of x(%i,:)',channel))
    
    subplot(312)
    plot(time,referenced(iChannel,:))
    hold on
    ylim([-2^15 2^15])
    title(sprintf('referenced timeseries of x(%i,:)',channel))
    
    subplot(313)
    plot(time,refSignal(iChannel,:))
    hold on
    ylim([-2^15 2^15])
    title(sprintf('reference signal of x(%i,:)',channel))
    
end
