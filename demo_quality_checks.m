% add required libraries
addpath('axona_io')
addpath('axona_preprocessing')
addpath('plotting')
addpath('quality_checks')
addpath('lfp')

% % define where data is
folderData = '/data/fred_old/Dataset Mouse 304/Converted no Ref';
filenameDataCommon = '304D1TFC';

folderOutput = '/data/fred_old/Dataset Mouse 304/results';

nTetrodes = 4;


% run quality checks on inputs (i.e. timestamps of events)
outputFilenameBase = sprintf('%s/qc_inputs_%s',folderOutput, filenameDataCommon);
qc_inputs(folderData, filenameDataCommon, outputFilenameBase);
% qc_inputs(folderData, filenameDataCommon); % will put the images in the current directory


% run quality checks on eeg data (i.e. whether timestamps at the right
% locations)
outputFilenameBase = sprintf('%s/qc_eeg_%s',folderOutput, filenameDataCommon);
qc_eeg(folderData, filenameDataCommon,4, outputFilenameBase)
% qc_eeg(folderData, filenameDataCommon,4) % will put the images in the current directory

