function [header,eeg_data] = read_eeg_file2(filename)
% READ_EEG_FILE reads a AXONA EEG data file into MATLAB.
%
% Input:
%     filename    ... String. Filename, typically ending in ".eeg" (see
%                     below and DACQ file format documentation)
%
% Output:
%     header      ... Struct. Structure containing key-value pairs from the
%                     header section of the tetrode file.
%
%     eeg_data    ... Double [nSamples x % 1] Array. Timestamps in
%                     seconds of when the spikes happened.
%
%
% From the DACQ file format documentation:
%
% EEG data is usually recorded continuously at 250 Hz in unit recording
% mode. The “.eeg” and “.eg2” files contain the data from the primary and
% secondary EEG channels, if these have been enabled. Very simply, the data
% consist of “num_EEG_samples” data bytes, following on from the
% data_start. The sample count is specified in the header. The “.egf” file
% is stored if a user selects a higher-sample rate EEG. Samples are
% normally collected at 4800 Hz (specified in the header), and are also
% normally 2 bytes long, rather than just 1.
%
% see also: READ_TETRODE_FILE, READ_INPUT_FILE

% Define AXONA-related constants
%--------------------------------------------------------------------------
% how is the data-stream flanked?
DATA_START_TOKEN = sprintf('\r\ndata_start');
DATA_END_TOKEN = sprintf('\r\ndata_end');

% how large should we expect the header-portion to be, maximally?
MAX_HEADER_SIZE = 1 * 1024^2; % in MB

% how large a section of the file (counting from the end-of-file) should we
% inspect to find the DATA_END_TOKEN?
TAIL_SIZE = 1024; % in bytes - no tail expect, so keep this short

% Open file
% -------------------------------------------------------------------------
f = fopen(filename,'r');
if f == -1
    warning('Cannot open file %s!', filename);
    header = struct(); eeg_data = [];
    return;
end

% first, identify header and data sections
%--------------------------------------------------------------------------
% identify where data starts
fileContent = fread(f, MAX_HEADER_SIZE, 'uint8=>char')'; % read binary file as if it was a text-file
dataStart = strfind(fileContent, DATA_START_TOKEN);

% identify where data ends, by jumping to tail of file and look for
% end-toke
fileStats = dir(filename);
fseek(f,fileStats.bytes - TAIL_SIZE,'bof');
fileContent = fread(f, Inf, 'uint8=>char')';
dataEnd = strfind(fileContent, DATA_END_TOKEN);

dataOffset = dataStart + length(DATA_START_TOKEN) - 1;

% read in header
%--------------------------------------------------------------------------
frewind(f); % go back to start of file
headerString = fread(f, dataStart-1, 'uint8=>char')';
% to read in data, we need to advance by the length of the DATA_START_TOKEN
fseek(f, dataStart + length(DATA_START_TOKEN) -1,'bof'); % relative to start of file

% convert header
%--------------------------------------------------------------------------
cell_array = textscan(headerString,'%s %[^\n\r]'); % split into keys and values
cell_array{2} = cellfun(@convertToNumber, cell_array{2},'UniformOutput',false); % % convert all numeric ones into numbers, keep string otherwise
header = cell2struct(cell_array{2},cell_array{1});
% manually post-process timebase and sample_rate: they include 'hz' so the
% above didn't convert them into numbers
% header.timebase = convertToNumber(header.timebase(1:(end-3))); % remove ' hz' from the end
header.sample_rate = str2num(header.sample_rate(1:(end-3))); % remove ' hz' from the end

% create memory map of eeg data
%--------------------------------------------------------------------------
switch header.bytes_per_sample
    case 1
        intType = 'int8';
    case 2
        intType = 'int16';
    otherwise
        error('unhandled bytes-per-sample');
end

dataFormat = intType;
dataLength = dataEnd-dataStart-length(DATA_START_TOKEN)

mmap = memmapfile(...
    filename,...
    'Format',dataFormat,...
    'Offset',dataOffset, ...
    'Repeat',header.num_EEG_samples,...
    'Writable',false...
    );

eeg_data = mmap.Data;
end