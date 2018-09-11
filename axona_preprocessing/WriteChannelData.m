function packets_matrix = WriteChannelData(filename, X_new, packets_matrix, packetsToWrite)


% add .bin extension if it is missing
[~,~,ext] = fileparts(filename);
if ~strcmp(ext, '.bin')
    filename = sprintf('%s.bin',filename);
end

% assert(~exist(filename,'file'), 'file %s already exists. Choose another filename', filename);


% define default packetsToWrite value
if ~exist('packetsToWrite','var')
    packetsToWrite = [];
end

GetDacqConstants;

% re-order channels so that they match the scheme expected by Dacq
X_new = X_new(axona_channel_mapping(1:64,'indexToChannel'),:);

% reshape data_matrix, such that every 3 (i.e. nSamplesPerPackage) samples
% are "concatenated" into a single package. This will tripple the
% "channels" and shorten the "length" of the data-matrix
data_matrix = [...
    X_new(:,1:nSamplesPerPackage:end); ...
    X_new(:,2:nSamplesPerPackage:end); ...
    X_new(:,3:3:end) ...
    ];

% figure out where we'll be inserting the data into the packets
indexStarting = 1 + NR_OF_BYTES_FOR_HEADER/2; % divide by 2 because of 'int16' conversion during `fread`
indexEnding = indexStarting-1 + NR_OF_BYTES_FOR_DATA/2; % divide by 2 because of 'int16' conversion during `fread`
assert(indexEnding == (NR_OF_BYTES_PER_PACKET/2 - NR_OF_BYTES_FOR_TAIL/2), ...
    'Error: length of data-matrix inconsistent with tail length (NR_OF_BYTES_FOR_TAIL)');

% insert this "compressed" data_matrix into the packages_matrix:
packets_matrix(indexStarting:indexEnding, :) = data_matrix;

if isempty(packetsToWrite) % i.e. no offset required
    % open file in write mode - this will overwrite the existing file
    fileID = fopen(filename, 'w');
    
else % i.e. offset required
    % open file in append mode - this will not remove any previous data
    fileID = fopen(filename, 'a');
    
    % calculate the desired offset in bytes
    offset = (packetsToWrite(1)-1) * NR_OF_BYTES_PER_PACKET;
    
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