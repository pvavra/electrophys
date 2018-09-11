% This script can be used to compare raw (.bin) files, which belong to
% the same recording session (i.e. only one .inp file for both). 
% 
% This might be useful to compare different reference signals, or to
% compare the raw recording in comparison to the one where the
% shock-time-window has already been removed and the electrodes referenced
% (aka preprocessed).

%% Setup & Initialization
%==========================================================================
% load modules which we need
addpath('axona_io')
addpath('axona_preprocessing')
addpath('lfp')

dataFilenameInput =  '/data/fred_old/Dataset Mouse 304/Converted no Ref/304D1TFC.inp';
files{1} =    '/data/fred_old/Dataset Mouse 304/Raw/304D1TFC.bin';
files{2} = '/data/fred_old/Dataset Mouse 304/Raw/304D1TFC_preprocessed.bin';
files{3} = '/data/fred_old/Dataset Mouse 304/Converted no Ref//304D1TFC_shocksRemoved.bin';

% define which channel we'll be checking
channels = 1:16;

% we'll be plotting only down-sampled data
samplingRate_low = 50; % in Hz

% for an overview of the whole timeseries, we downsample even further, to
% avoid overwhelming matlab with too many data-points for plotting
maxDataPoints = 10000;

% Load AXONA constants
GetDacqConstants;

%% Load timestamps
%==========================================================================
% load Inputs
inputs = LoadInputs(dataFilenameInput);

% get all timestamps of the shock
[shock_timestamps, shock_durations] = GetEventsOfInterest(inputs, 'shock');

fprintf('inputs loaded\n');

%% Load & downsample binary data
%==========================================================================
for iFile = 1:numel(files)
    fprintf('loading and downsampling file: %s\n', files{iFile});
    [dataCurrent, ~, ~] = GetChannelData(files{iFile});
    
    % Downsample binary data
    data(:,:,iFile) = downsample(dataCurrent(channels,:)', ...
        round(SAMPLING_FREQUENCY / samplingRate_low)...
        );
    
    % remove full data, to avoid overrunning memory with large binary files
    clear dataCurrent
end
fprintf('data loaded\n');

%% Loop over all channels, creating plots for each
%==========================================================================
for iChannel = 1:length(channels)
    % Overview plot of whole timeseries
    %----------------------------------------------------------------------
    % get current length of data
    nDataPoints = size(data,1);
    
    % calculate how much we need to downsample
    dropNPoints = ceil(nDataPoints / maxDataPoints);
    
    % downsample
    dataOverview = downsample(squeeze(data(:,iChannel,:)),dropNPoints);
    
    % infer time-axis
    samplingRate = samplingRate_low / dropNPoints;
    time = (0:(size(dataOverview,1)-1))/samplingRate;
    
    % create plot
    figure(100 + iChannel)
    clf
    plot(time,dataOverview)
    legend(files)
    xlabel('time [s]')
    xlim([min(time) max(time)])
    ylim([-2^15 2^15])
    title(sprintf('Timeseries of channel %i',channels(iChannel)))
    
    % Plotting time-windows around shocks
    %----------------------------------------------------------------------
    % sanity check part three: plot comparison of before/after
    nRows = length(shock_timestamps); % nRows = nShocks
    nCols = 1;
    
    figure(200 + iChannel)
    clf
    for iRow = 1:nRows
        % define timewindow index ranges around shock, with downsampled
        % sampling rate taken into account; Here, the time-window starts 1
        % second before shock and ends eleven seconds later
        indexStart = round((shock_timestamps(iRow)-1) * samplingRate_low);
        indexEnd = round((shock_timestamps(iRow) + 11) * samplingRate_low);
        indexRange = indexStart:indexEnd;
        
        % define time-axis
        time = indexRange / samplingRate_low;
        
        % start plotting
        subplot(nRows, nCols, iRow)
        plot(time, squeeze(data(indexRange,iChannel,:)));
        
        legend(files)
        title(sprintf('Channel %i: Time-window around shock %i',channels(iChannel), iRow));
        xlabel('time [s]')
        ylim([-2^15 2^15])
        xlim([min(time) max(time)])
        
    end
end
