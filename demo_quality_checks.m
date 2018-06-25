% add required libraries
addpath('../axona_io')
addpath('axona_preprocessing')
addpath('libs/barwitherr') % for plotting errorbars on top of bar-plots
addpath('plotting')
addpath('quality_checks')


% define where data is
folderData = '/data/fred/Dataset Mouse 304/Converted no Ref';
filenameDataCommon = '304D1TFC';
nTetrodes = 4;

% load eeg data
eeg_filename = sprintf('%s/%s.eeg', folderData, filenameDataCommon);
[header, eeg] = read_eeg_file(eeg_filename);

% run quality control check
figure(1)
set(gcf, 'Name',sprintf('EEG data QC of `%s`', filenameDataCommon))

% Plot first n seconds to see signal
subplot(421)
PlotEEGTimeseries(...
    eeg, ...
    0, ... % tmin
    100, ... %max
    header.sample_rate...
    )

% plot associated histogram over y-values
subplot(422)
PlotEEGHistogram(...
    eeg, ...
    0, ... % tmin
    5, ... % max
    header.sample_rate, ...
    100 ... % nBins
)
% rotate plot
view([90 -90])

% Plot first n seconds to see signal
subplot(423)
PlotEEGTimeseries(...
    eeg, ...
    0, ... % tmin
    5, ... %max
    header.sample_rate...
    )
