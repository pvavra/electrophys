% this script shows how to remove signal from the raw timeseries around the
% shock. 
% 
% It assumes that a .inp file has already been created (e.g. by converting
% the .bin into .eeg/.egf files. 
% 
% 

%% expand path
addpath('axona_preprocessing')
addpath('../axona_io')


%% Setup
% define where the data is
folderData = '/data/fred/Dataset Mouse 304/Converted no Ref';
filenameDataCommon = '304D1TFC';
filenameDataCommon = sprintf('%s/%s', folderData, filenameDataCommon); % convert to full-path version

% define how to call the new file, and where to put it
filenameOutput = '304D1TFC_shocksRemoved'; % will get .bin-extension automatically
folderOutput = folderData; % put resulting file in the same as the original data
filenameOutput = sprintf('%s/%s',folderOutput,filenameOutput); % prepend the folder where to put the data, to convert to full-path version

% define how much to remove
removeStart = 0; % in seconds, relative to shock-onset - will be subtracted from onset-timestamp
removeEnd = 10; % in seconds, relative to shock onset 

%% Load Inputs

% load inputs
inputs = LoadInputs(filenameDataCommon); 

% get all timestamps of the shock
[shock_timestamps, shock_durations] = GetEventsOfInterest(inputs, 'shock'); 


%% load raw datat
tic
[data_matrix, fileStats, packets_matrix] = GetChannelData(filenameDataCommon);
toc

%% convert timestamps into "sample-stamps"
% the .inp file contains timestamps, but the .bin file has no explicit
% time-axis. So we need to convert e.g. a timestamp of 1s to which sample
% that corresponds. This means we need to multiply the timestamps by the
% sampling rate (a timestamp at "1s" thus corresponds to the 48000th
% sample). Let's call the result of this conversion 'sample-stamps', in
% analogy to timestamps. 

% first, define which the start/end timestamps of what needs to be removed
removeStart_timestamps = shock_timestamps - removeStart; 
removeEnd_timestamps = shock_timestamps + removeEnd; 


% convert time stamp to sample number
removeStart_samplestamps = round(removeStart_timestamps .* fileStats.SamplingFrequency); % rounding to avoid that these are non-integers
removeEnd_samplestamps = round(removeEnd_timestamps .* fileStats.SamplingFrequency);

% convert the start/end "sample stamps" into index-ranges 
% there are as many index ranges
indexRanges = [];
for iIndexRange = 1:length(removeStart_samplestamps)
    currentIndexRange = removeStart_samplestamps(iIndexRange):removeEnd_samplestamps(iIndexRange);
    
    % append to existing list:
    indexRanges = [indexRanges currentIndexRange];
end

%% sanity check part one: grab timeseries before altering it
% let's grab a downsampled version of the data before deleting any of it,
% for comparing it with the removed one

samplingRate_low = 250; %Hz
whichChannel = 1;  % define which channel we'll be checking

data_before = downsample(data_matrix(whichChannel,:), round(fileStats.SamplingFrequency / samplingRate_low));


%% remove data around shock
% set data in time-windows to zero
data_matrix(:,indexRanges) = 0;

%% sanity check part two: grab timeseries after
data_after = downsample(data_matrix(whichChannel,:), round(fileStats.SamplingFrequency / samplingRate_low));

%% sanity check part three: plot comparison of before/after
nRows = length(shock_timestamps); % nRows = nShocks
nCols = 1;

f = figure(191)
clf
set(gcf,'Name',sprintf('Timeseries of channel %i around the %i shocks', whichChannel, nRows));
for iRow = 1:nRows
    % define timewindow index ranges around shock, with downsampled sampling
    % rate, but also plot one second before and one second after removed
    % section
    indexStart = round((removeStart_timestamps(iRow)-10) * samplingRate_low);
    indexEnd = round((removeEnd_timestamps(iRow) + 10) * samplingRate_low);
    indexRange = indexStart:indexEnd;
    
    % define time-axis
    time = indexRange / samplingRate_low; 
    
    % start plotting
    subplot(nRows, nCols, iRow)
    plot(time,data_before(whichChannel, indexStart:indexEnd),'r', 'DisplayName', 'before removing')
    hold on
    plot(time,data_after(whichChannel, indexStart:indexEnd),'b', 'DisplayName', 'after removing')
    legend
    title(sprintf('Timewindow around shock %i',iRow));
    xlabel('time [s]')
    ylim([-2^15 2^15])
end

%% save figure to file, for logging of quality control
set(gcf, 'Units', 'pixels', 'Position', [0 0 1920 1080]); % set size of image to fullHD
saveas(gcf, sprintf('%s/qc_removingDataAroundShocks.jpg', folderOutput));

%% write out file
WriteChannelData(filenameOutput, data_matrix, packets_matrix); 




