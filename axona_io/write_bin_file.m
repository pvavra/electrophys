function write_bin_file(filename, data_new, packets_matrix, packetsRange)
% write_bin_file(filename, X_new, packets_matrix, packetsToWrite) writes an
% AXONA .bin file to disk.  
%
% Input:
%      filename         ... String. full-path filename of the binary Axona
%                           file
%
%      data_new        ... [64 x time] int16 array of channel data.
%                           Channel 1 is expected in position `data(1,:)`
%                           and will be re-sorted into axona position by
%                           this function before writing it to file.
%      
%      packets_matrix  ... [packets x time] int16 array. This is the 'raw'
%                           packets timeseries. The content of data_new
%                           will be inserted into this matrix (after
%                           re-shuffling the channels appropriately). 
% 
%      packetsRange     ... (optional) [2 x 1] vector of integers. If
%                           provided, this will load packets in the range
%                           [from to]. Use this to load only, e.g. packets
%                           100:200 by adding "[100 200]" to the function
%                           input. If not provided (or explicitly "[]"), it
%                           will load all packets. default: []
%
% SEE ALSO:
%  READ_BIN_FILE


% add .bin extension if it is missing
[~,~,ext] = fileparts(filename);
if ~strcmp(ext, '.bin')
    filename = sprintf('%s.bin',filename);
end




% define default packetsToWrite value
if ~exist('packetsRange','var')
    packetsRange = [];
end

GetDacqConstants;

% re-order channels so that they match the scheme expected by Dacq
data_new = data_new(axona_channel_mapping(1:64,'indexToChannel'),:);

% reshape data_matrix, such that every 3 (i.e. nSamplesPerPackage) samples
% are "concatenated" into a single package. This will tripple the
% "channels" and shorten the "length" of the data-matrix
data_matrix = [...
    data_new(:,1:nSamplesPerPackage:end); ...
    data_new(:,2:nSamplesPerPackage:end); ...
    data_new(:,3:3:end) ...
    ];

% figure out where we'll be inserting the data into the packets
indexStarting = 1 + NR_OF_BYTES_FOR_HEADER/2; % divide by 2 because of 'int16' conversion during `fread`
indexEnding = indexStarting-1 + NR_OF_BYTES_FOR_DATA/2; % divide by 2 because of 'int16' conversion during `fread`
assert(indexEnding == (NR_OF_BYTES_PER_PACKET/2 - NR_OF_BYTES_FOR_TAIL/2), ...
    'Error: length of data-matrix inconsistent with tail length (NR_OF_BYTES_FOR_TAIL)');

% insert this "compressed" data_matrix into the packages_matrix:
packets_matrix(indexStarting:indexEnding, :) = data_matrix;

if isempty(packetsRange) % i.e. no offset required
    % open file in write mode - this will overwrite the existing file
    fileID = fopen(filename, 'w');
    
else % i.e. offset required
    % open file in append mode - this will not remove any previous data
    fileID = fopen(filename, 'a');
    
    % calculate the desired offset in bytes
    offset = (packetsRange(1)-1) * NR_OF_BYTES_PER_PACKET;
    
    % assert that we can put the data at the desired offset
    fileStats = dir(filename);
    assert(offset <= fileStats.bytes, ...
        'the desired offset (packetsToWrite(1)) is not possible: too few packets exist already in the file (at least %i required, but only %i found)',...
        offset / NR_OF_BYTES_PER_PACKET, ...
        fileStats.bytes / NR_OF_BYTES_PER_PACKET...
        );
    
    % jump to the required offset
    fseek(fileID, offset,'bof');
end

fwrite(fileID, packets_matrix(:),'int16');

% close file again
fclose(fileID);

end