% This scripts shows how to preprocess raw (.bin) datasets, by referencing
% (mean-referencing is shown, but others are available) and by removing a
% time-window around the shock.
%
% NOTE: For each dataset which is to be processed, both the raw (.bin file)
% and exported LFP (.egf & .inp files) are required.
% 

%% Initialization
% load modules which we need
addpath('axona_io')
addpath('axona_preprocessing')
addpath('lfp')

% preprocessing will be performed in chuncks, so that we do not run out of
% RAM. Specify chunck-size in multiples of packets (one packet has 432
% bytes). Note: there are 16000 packets in one second of recording
chunkSize = 10 * 60 * 16000; % number of Packets. 

% define where the data is/will go
dataFilenameRaw =    '/data/fred_old/Dataset Mouse 304/Raw/304D1TFC.bin';
dataFilenameInput =  '/data/fred_old/Dataset Mouse 304/Converted no Ref/304D1TFC.inp'; 
dataFilenameOutput = '/data/fred_old/Dataset Mouse 304/Raw/304D1TFC_preprocessed.bin'; 

% define how to reference the electrodes, and into which file to write them
% out; by providing a vector, we will reference to the mean of these
% channels
references = 1:16; 

% define time-window around shock which will be set to zero; Note: BOTH
% boundaries are relative to shock ONSET
removeStart = 0; % in seconds
removeEnd = 10; % in seconds

% load DACQ/AXONA constants:
GetDacqConstants;

%% Run preprocessing
% assert that both input and raw binary files exist
for file = {dataFilenameRaw, dataFilenameInput}
    assert(exist(file{:},'file') == 2, 'File "%s" does not exist', file{:});
end

% load Inputs
inputs = LoadInputs(dataFilenameInput);

% get all timestamps of the shock
[shock_timestamps, shock_durations] = GetEventsOfInterest(inputs, 'shock'); 

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


% convert time-stamp to sample number
removeStart_samplestamps = round(removeStart_timestamps .* SAMPLING_FREQUENCY); % rounding to avoid that these are non-integers
removeEnd_samplestamps = round(removeEnd_timestamps .* SAMPLING_FREQUENCY);

% convert the start/end "sample stamps" into index-ranges 
% there are as many index ranges
indicesShock = [];
for iIndexRange = 1:length(removeStart_samplestamps)
    currentIndexRange = removeStart_samplestamps(iIndexRange):removeEnd_samplestamps(iIndexRange);
    % append to existing list:
    indicesShock = [indicesShock currentIndexRange];
end

%% Now, we can loop over chunks
% first step is to figure out how many chuncks we'll need, given how large
% the file is. 
fileStats = dir(dataFilenameRaw);
nPackets = fileStats.bytes / 432;
nChunks = ceil(nPackets / chunkSize);

% When handling chunks, we cannot delete previously existing files
% automatically (using `fopen`), we need to manually remove the output file
% if it already exists
if exist(dataFilenameOutput, 'file') == 2
    delete(dataFilenameOutput);
end

for iChunk = 1:nChunks
    fprintf('processing chunk %i/%i\n',iChunk,nChunks);
     
    % load data
    %----------------------------------------------------------------------
    
    % which bytes belong to the current chunk? Provide a simple array of
    % the form: [from to] Note: for the end of the batch of packets,
    % we're using `min(x,nPackets)` to ensure that we never request to
    % process more packets than there are in the file
    packetsToProcess = [...
        1 + chunkSize * (iChunk - 1)... % offsetting indices by preceeding chunks
        min(chunkSize * iChunk, nPackets)... % end of current chunk
        ];
    
    % load relevant packets
    [data_matrix, fileStats, packets_matrix] = GetChannelData(dataFilenameRaw, packetsToProcess);
    
    % remove shocks
    %----------------------------------------------------------------------    
    % which samples are in the current chunk    
    samplesInCurrentChunk = (1+(packetsToProcess(1)-1)*3):(3*packetsToProcess(2)); 
    % which subset of these contains the shock:
    indexRangeCurrentChunk = intersect(samplesInCurrentChunk, indicesShock);
    
    if ~isempty(indexRangeCurrentChunk)
        fprintf('removing data in shock-timewindow\n');
        
        % convert these indices from "all" to "current chunk" indexing
        indicesToRemove = indexRangeCurrentChunk - (iChunk-1) * chunkSize * 3;  
        assert(max(indicesToRemove) <= size(data_matrix,2),...
            'Index Conversion Failed: some index to remove is larger than the available data-matrix size');
        
        % set data in time-windows to zero
%         data_old = data_matrix;
        data_matrix(:,indicesToRemove) = 0;
    end
    
%     if size(data_old) ~= size(data_matrix)
%         fprintf('size(data_old,2) = %g\nsize(data_matrix,2) = %g\n',  ...
%             size(data_old,2),...
%             size(data_matrix,2)...
%             );
%     end
    
    % reference signal
    %----------------------------------------------------------------------
    fprintf('referencing channels of current chunk\n');
    [refencedData, ~] = ReferenceData(data_matrix, references);
    
    % write data to file
    %----------------------------------------------------------------------
    WriteChannelData(dataFilenameOutput , refencedData, packets_matrix, packetsToProcess);
end
