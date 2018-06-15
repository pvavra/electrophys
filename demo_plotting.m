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


%% Plot: scatter plot w/ epochs overlayed based on input
for iTetrode = 1%:nTetrodes
    
    subsetOfUnits = [3 5 8];
    
    % Rasterplots & histograms
    %----------------------------------------------------------------------
    figure(iTetrode)
    set(gcf,'Name', sprintf('Rasterplots & Histograms- Tetrode %i', iTetrode))
    subplot(221)
    PlotRaster(inputs, spikes(iTetrode), 'all');
        
    subplot(223)
    PlotRaster(inputs, spikes(iTetrode),subsetOfUnits );
    
    subplot(222)
    PlotHistogram(inputs,spikes(iTetrode), 'all', 1 );
    
    subplot(224)
    PlotHistogram(inputs,spikes(iTetrode), subsetOfUnits, 1 );
    
    
    % Mean Firing Rate Changes
    %----------------------------------------------------------------------
    figure(iTetrode + nTetrodes)
    set(gcf,'Name', sprintf('Firing Rate Change - Tetrode %i', iTetrode))
    
    % for the trace period:
    subplot(321)
    PlotFiringRateChange(inputs, spikes(iTetrode), 'trace', 'all')
    
    subplot(322)
    PlotFiringRateChange(inputs, spikes(iTetrode), 'trace', subsetOfUnits, 0)

    subplot(324)
    PlotFiringRateChange(inputs, spikes(iTetrode), 'trace', subsetOfUnits, 1) % average
    
    % for the tone period:
    subplot(323)
    PlotFiringRateChange(inputs, spikes(iTetrode), 'baseline', subsetOfUnits, 0)

    subplot(325)
    PlotFiringRateChange(inputs, spikes(iTetrode), 'tone', 'all', 0)

    % and for the shock:
    subplot(326)
    PlotFiringRateChange(inputs, spikes(iTetrode), 'after-shock', 'all', 1)
    
end





