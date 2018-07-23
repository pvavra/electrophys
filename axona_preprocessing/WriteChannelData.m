function packets_matrix = WriteChannelData(filename, X_new, packets_matrix)
% add .bin extension if it is missing
[~,~,ext] = fileparts(filename);
if ~strcmp(ext, '.bin')
    filename = sprintf('%s.bin',filename);
end

assert(~exist(filename,'file'), 'file %s already exists. Choose another filename', filename);

GetDacqConstants;

% re-order channels so that they match the scheme expected by Dacq
X_new = X_new(axona_channel_mapping(1:64,'indexToChannel'),:);

% reshape data_matrix, such that every 3 (i.e. nSamplesPerPackage) samples
% are "concatenated" into a single package. This will tripple the
% "channels" and shorten the "length" of the data-matrix
% 
% IMPROVE: generalize this to use nSamplesPerPackage instead of hard-coded "3"
data_matrix = [X_new(:,1:3:end); X_new(:,2:3:end); X_new(:,3:3:end)];

% insert this "compressed" data_matrix into the packages_matrix: 
indexStarting = 1 + NR_OF_BYTES_FOR_HEADER/2; % divide by 2 because of 'int16' conversion during `fread`
indexEnding = indexStarting-1 + NR_OF_BYTES_FOR_DATA/2; % divide by 2 because of 'int16' conversion during `fread`
assert(indexEnding == (NR_OF_BYTES_PER_PACKET/2 - NR_OF_BYTES_FOR_TAIL/2), 'Error: length of data-matrix inconsistent with tail length (NR_OF_BYTES_FOR_TAIL)');
packets_matrix(indexStarting:indexEnding, :) = data_matrix;

% write data to file
fileID = fopen(filename, 'w');
fwrite(fileID, packets_matrix(:),'int16');
fclose(fileID);

end