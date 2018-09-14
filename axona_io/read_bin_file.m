function [data_matrix, fileStats, packets_matrix] = read_bin_file(filename, packetsRange)
% [data_matrix, fileStats, packets_matrix] = read_bin_file(filename)
% Reads in .bin AXONA data file
%
% Input:
%      filename         ... String. full-path filename of the binary Axona
%                           file
%
%      packetsRange     ... (optional) [2 x 1] vector of integers. If
%                           provided, this will load packets in the range
%                           [from to]. Use this to load only, e.g. packets
%                           100:200 by adding "[100 200]" to the function
%                           input. If not provided (or explicitly "[]"), it
%                           will load all packets. default: []
%
% Output:
%       data_matrix     ... [channel x time] int16 array. The full data of
%                           of all channels (even empty ones), as stored in
%                           the .bin file
%
%       fileStats       ... struct. Basic info on the .bin file, like number
%                           of packets, total recording duration and
%                           sampling frequency.

%       packets_matrix  ... [packets x time] int16 array. This is the 'raw'
%                           packets timeseries. This is handy for not
%                           having to handle header/tail of each packet,
%                           and be able to write out to the binary format,
%                           while changing only the `data_matrix` portion
%                           of the packets.
% SEE ALSO:
%  WRITE_BIN_FILE


% if `filename` does not end in `.bin`, append that to `filename`
[~, ~, ext ] = fileparts(filename);
if ~strcmp(ext, '.bin')
    filename = sprintf('%s.bin', filename);
end

assert(exist(filename,'file') == 2, 'file %s does not exist', filename);

GetDacqConstants;

% define default range of samples
if ~exist('packetsRange','var')
    packetsRange = [];
end

%% calculate a few stats on data-file for header
fileStats = struct();
listing = dir(filename);
fileStats.sizeInBytes = listing(1).bytes;
fileStats.nPackets = fileStats.sizeInBytes/NR_OF_BYTES_PER_PACKET;
fileStats.nSamples = fileStats.nPackets * nSamplesPerPackage;
fileStats.recordingLength_inSeconds = fileStats.nSamples / SAMPLING_FREQUENCY; % in seconds
fileStats.SamplingFrequency = SAMPLING_FREQUENCY;


fileID = fopen(filename, 'r');

if ~isempty(packetsRange)
    % first, assert that desired sampleRange is possible:
    %----------------------------------------------------------------------
    
    % the desired beginning must be inside the file
    assert(packetsRange(1) <= fileStats.nPackets,...
        'Desired packets-range starts with a higher value (%i) than is possible (nPackets = %i)',...
        packetsRange(1),fileStats.nPackets);
    % if upper bound is too high, give a warning and reset it to the end of
    % the file
    if (packetsRange(2) > fileStats.nPackets)
        warning(['Desired packets-range ends with a higher value (%i) than is possible (nPackets = %i)\n'...
            'will set upper bound to its maximal valid value (i.e. nPackets)'],...
            packetsRange(2),fileStats.nPackets);
        packetsRange(2) = fileStats.nPackets;
    end
    
    % load desired range of data
    fseek(fileID, (packetsRange(1)-1) * NR_OF_BYTES_PER_PACKET, 'bof'); % jump to desired starting position
    nrOfBytesToLoad = (packetsRange(2)-packetsRange(1) + 1)* NR_OF_BYTES_PER_PACKET / 2;
else
    % no range specified, load all data
    fseek(fileID,0,'bof');
    nrOfBytesToLoad = fileStats.sizeInBytes / 2;
end

% load desired data
packets_matrix = fread(fileID, nrOfBytesToLoad ,'int16=>int16');

% Each channel's data is coded in 2 bytes using two's complement coding
% scheme. To avoid having to read each part of the packet (header vs data)
% with different `precision` settings, we use only the one relevant to the
% data-part of the package, namely 'int16'. This mean though, that the
% header is "shortened" to half it's length, as is the trail. This means
% that we need to divide the number of bytes per packet by two, when
% reshaping the resulting matrices.
packets_matrix  = reshape(packets_matrix , NR_OF_BYTES_PER_PACKET/2,[]);

%% Extract data from packets
% select only data from packets
indexStarting = 1 + NR_OF_BYTES_FOR_HEADER/2; % divide by 2 because of 'int16' conversion during `fread`
indexEnding = indexStarting-1 + NR_OF_BYTES_FOR_DATA/2; % divide by 2 because of 'int16' conversion during `fread`
assert(indexEnding == (NR_OF_BYTES_PER_PACKET/2 - NR_OF_BYTES_FOR_TAIL/2), 'Error: length of data-matrix inconsistent with tail length (NR_OF_BYTES_FOR_TAIL)');

data_matrix = packets_matrix(indexStarting:indexEnding, :);

% reshape data_matrix, to take into account that multiple samples are
% stored within one package:
data_matrix = reshape(data_matrix, size(data_matrix,1) / nSamplesPerPackage, []);

% re-sort channels so that channel 1 is in data_matrix(1,:), channel 2 in
% data_matrix(2,:) etc.
data_matrix = data_matrix(axona_channel_mapping(1:64,'channelToIndex'),:);

fclose(fileID);

end