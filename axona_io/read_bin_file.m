function [header,data] = read_bin_file(filename)
% READ_BIN_FILE reads a AXONA binary (i.e. raw) data file into MATLAB.
%
% Input:
%     filename    ... String. Filename, typically ending in ".bin" (see
%                     below and DACQ file format documentation)
%
% Output:
%     header      ... Struct. Structure containing key-value pairs from the
%                     header section of the tetrode file.
%
%     data        ... Double [nSamples x % 1] Array. Timestamps in
%                     seconds of when the spikes happened.
%
%
% From the DACQ file format documentation:
%
% see also: READ_TETRODE_FILE, READ_INPUT_FILE, READ_EEG_FILE


BYTES_PER_PACKAGE = 432; 
BYTES_FOR_HEADER = 4 + 4 + 2 + 2 + 20;
BYTES_FOR_TAIL = 16;

BatchSize = BYTES_PER_PACKAGE * 100;

f = fopen(filename,'r');
if f == -1
    warning('Cannot open file %s!', filename);
    header = struct(); data = [];
    return;
end

% read all samples in
%--------------------------------------------------------------------------
rawBinaryData = fread(f, BatchSize, 'int16=>int16')'; % read binary file
rawBinaryData = reshape(rawBinaryData,BYTES_PER_PACKAGE/2,[]); % we read in int16

% split off header/data
%--------------------------------------------------------------------------
indicesHeader = 1:BYTES_FOR_HEADER/2;
indicesData = (BYTES_FOR_HEADER/2+1):(BYTES_PER_PACKAGE-BYTES_FOR_TAIL)/2;
header = rawBinaryData(indicesHeader ,:); 
data = rawBinaryData(indicesData, :);
data = reshape(data,64,[]); 


% convert data into samples x channels x bits format:
%--------------------------------------------------------------------------
