addpath('axona_preprocessing')
addpath('lfp')

%% load data
% dataFilename = '/data/fred/Dataset Mouse 304/Raw/304D1TFC.bin'; % 9GB
dataFilename = '/data/fred/pilot_data/Gain 6000 Direct Avg 24kHz 1005um/1556.bin'; % <1GB


fprintf('loading data\n')
tic
[data_matrix, fileStats, packets_matrix] = GetChannelData(dataFilename);
toc

% fprintf('write copy of data to disk\n')
% tic
% filename_output = '/data/fred/Dataset Mouse 304/Raw/304D1TFC_copy.bin';
% WriteChannelData(filename_output , data_matrix, packets_matrix);
% toc

references = {...
    1:16; ...
    1; ...
    };

filenames_output = {...
    '/data/fred/Dataset Mouse 304/Raw/304D1TFC_ReferencedToMean.bin'; ...
    '/data/fred/Dataset Mouse 304/Raw/304D1TFC_ReferencedToFirst.bin' ...
    };

%% reference signal
for iReferencing = 1:length(references)
    
    fprintf('referencing to %s\n', mat2str( references{iReferencing}));
    tic
    [ref, ~] = ReferenceData(data_matrix, references{iReferencing});
    toc
    
    fprintf('writing referenced data to file\n');
    tic
    WriteChannelData(filenames_output{iReferencing} , -ref, packets_matrix);
    toc
end


