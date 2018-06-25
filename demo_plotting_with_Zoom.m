addpath('../axona_io')
addpath('axona_preprocessing')
addpath('libs/barwitherr') % for plotting errorbars on top of bar-plots
addpath('plotting')

folderData = '/home/petvav/ownCloud/Documents/projects/fred/matlab_scripts_for_fred/data';
% how are the files called - provide the part which is shared among them
filenameDataCommon = '1.8HP1.0LP55.1_modified';

% folderData = '/data/fred/Conditioning Data Full with inp/304D1TFC Converted Spikes EEG';
% filenameDataCommon = '304D1TFC Converted Spikes';

% number of channels, i.e. files ending in .1, .2, etc., up-to nChannels
nTetrodes = 4;

[inputs, spikes] = LoadData(...
    sprintf('%s/%s', folderData, filenameDataCommon), ... % make it 'fullpath'
    nTetrodes ...
    );

%% Plot
iTetrode = 1;

timestamps = cell2mat(spikes(iTetrode).timestamps(:));
maxTimestamp = max(timestamps+1); % include one second after largest timestamp
minTimestamp = min([timestamps-1;0]); % make sure to include 0, and 1 second before the earliest timestamp, in case there are negative ones


figure(iTetrode)
set(gcf,'Name', sprintf('Rasterplot with Zoom - Tetrode %i', iTetrode))

subplot(311)
ax1 = PlotRaster(inputs, spikes(iTetrode), 'all');
AddSliderOffset(minTimestamp,maxTimestamp, ax1, [10 900 120 20]);
AddSliderZoom(minTimestamp, maxTimestamp, ax1, [10 850 120 20]);

subplot(312)
ax2 = PlotRaster(inputs, spikes(iTetrode), [1,3,7]);
AddSliderOffset(minTimestamp,maxTimestamp, ax2, [10 550 120 20]);
AddSliderZoom(minTimestamp, maxTimestamp, ax2, [10 500 120 20]);

subplot(313)
ax3 = PlotHistogram(inputs, spikes(iTetrode),'all', 1);
AddSliderOffset(minTimestamp,maxTimestamp, ax3, [10 200 120 20]);
AddSliderZoom(minTimestamp, maxTimestamp, ax3, [10 150 120 20]);