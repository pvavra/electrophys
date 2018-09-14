addpath('axona_io')
addpath('axona_preprocessing')
addpath('libs/barwitherr') % for plotting errorbars on top of bar-plots
addpath('plotting')

% folderData = '/home/petvav/ownCloud/Documents/projects/fred/matlab_scripts_for_fred/data';
% how are the files called - provide the part which is shared among them
% filenameDataCommon = '1.8HP1.0LP55.1_modified';

folderData = '/data/fred_old/Conditioning Data Full with inp/304D1TFC Converted Spikes EEG';
filenameDataCommon = '304D1TFC Converted Spikes';

% number of channels, i.e. files ending in .1, .2, etc., up-to nChannels
nTetrodes = 4;

[inputs, spikes] = LoadData(...
    sprintf('%s/%s', folderData, filenameDataCommon), ... % make it 'fullpath'
    nTetrodes ...
    );

% Specify whether to save figures to file. If yes, the next variables need
% to be set as well. NOTE: any existing images will be overwritten without
% a warning!
saveFigures = true; % yes/no on whether to save figures to file.
% if figures should be saved, specify the folder where to put them
folderOutput = '/data/fred_old/Dataset Mouse 304/results';
% define which resolution (dot-per-inch) to use. 300 is good for on-screen
% viewing, while 600 is good for (most) publications
dpi = 300;


%% Plot: scatter plot w/ epochs overlayed based on input
for iTetrode = 1%:nTetrodes
    
    subsetOfUnits = [3 5 8];
    
    % Rasterplots & histograms
    %----------------------------------------------------------------------
    figure(iTetrode)
    set(gcf,'Name', sprintf('Rasterplots & Histograms- Tetrode %i', iTetrode))
    subplot(321)
    PlotRaster(inputs, spikes(iTetrode), 'all');
        
    subplot(323)
    PlotRaster(inputs, spikes(iTetrode),subsetOfUnits );
    
    subplot(322)
    PlotHistogram(inputs,spikes(iTetrode), 'all', 1 );
    
    subplot(324)
    PlotHistogram(inputs,spikes(iTetrode), subsetOfUnits, 1 );
    
    subplot(325)
    PlotRasterTrials(inputs, spikes(iTetrode), 3);
    
    subplot(326)
    PlotHistrogramTrials(inputs, spikes(iTetrode), 3, 1);
    
    % save to file
    if saveFigures
        filename = sprintf('%s/rasters_tetrode%i',folderOutput, iTetrode);
        ExportFigure(filename, dpi);
    end
    
    
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
    
    
    % save to file
    if saveFigures
        filename = sprintf('%s/firingRateChanges_tetrode%i',folderOutput, iTetrode);
        ExportFigure(filename, dpi);
    end
    
end





