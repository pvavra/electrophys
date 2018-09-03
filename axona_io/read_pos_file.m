function [positions, header] = read_pos_file(filename, convertMissingPositionToNaN)

% AXONA-related constants
%--------------------------------------------------------------------------
% strings used to mark beginning/end of data-stream inside of file
DATA_START_TOKEN = sprintf('\r\ndata_start');
DATA_END_TOKEN = sprintf('\r\ndata_end');

% Preprocess function inputs
%--------------------------------------------------------------------------
% automatically add .pos if missing from `filename`
[~,~,ext] = fileparts(filename);
if ~strcmp(ext,'.pos')
    filename = sprintf('%s.pos', filename);
end
assert(exist(filename,'file')==2, 'File "%s" not found', filename);

% define default for: convertMissingPositionToNaN
if ~exist('convertMissingPositionToNaN','var')
    convertMissingPositionToNaN = false;
end

% Initialization
%--------------------------------------------------------------------------
header = []; positions = struct(); 

% Open file
%--------------------------------------------------------------------------
f = fopen(filename,'r');
if f == -1
    warning('Cannot open file %s!', filename);
    return;
end

% first, identify where header and data sections are
%--------------------------------------------------------------------------
fileContent = fread(f, Inf, 'uint8=>char')'; % read binary file as if it was a text-file
startData = strfind(fileContent, DATA_START_TOKEN);
endData = strfind(fileContent, DATA_END_TOKEN);

% read in header and data
%--------------------------------------------------------------------------
frewind(f); % go back to start of file
headerString = fread(f, startData-1, 'uint8=>char')';
% to read in data, we need to advance by the length of the DATA_START_TOKEN
fseek(f, startData + length(DATA_START_TOKEN) -1,'bof'); 
rawBinaryData = fread(f, endData-startData-length(DATA_START_TOKEN), '*int8'); % read data in as bytes

% convert header 
%--------------------------------------------------------------------------
cell_array = textscan(headerString,'%s %[^\n\r]'); % split into keys and values
cell_array{2} = cellfun(@convertToNumber, cell_array{2},'UniformOutput',false); % % convert all numeric ones into numbers, keep string otherwise
header = cell2struct(cell_array{2},cell_array{1});
% manually post-process timebase and sample_rate: they include 'hz' so the
% above didn't convert them into numbers
header.timebase = convertToNumber(header.timebase(1:(end-3))); % remove ' hz' from the end
header.sample_rate = str2num(header.sample_rate(1:(end-3))); % remove ' hz' from the end

% extract position data
%--------------------------------------------------------------------------
% the manual talks about two different modes, in which the binary data can
% be stored. For now, only one is handled here

switch header.pos_format
    case 't,x1,y1,x2,y2,numpix1,numpix2'
        rawBinaryData = reshape(rawBinaryData,20,[]); % there are 20 byetes for each position sample
        
        positions.t = rawBinaryData(1:4,:); % the first four bytes are the frame counter
        positions.x1 = rawBinaryData(5:6,:);
        positions.y1 = rawBinaryData(7:8,:);
        positions.x2 = rawBinaryData(9:10,:);
        positions.y2 = rawBinaryData(11:12,:);
        positions.numpix1 = rawBinaryData(13:14,:);
        positions.numpix2 = rawBinaryData(15:16,:);
        positions.totalpix = rawBinaryData(17:18,:);
    otherwise
        error('unknown position format of binary data: %s', header.pos_format);
end

% loop over all attributes of position, and convert to double, taking into
% account that we might need to swap bytes
[~,~,endian] = computer;  % 'L' or 'B'
fields = fieldnames(positions);
for i=1:length(fields)
    
    % convert current field to `int16`, except for the frame counter
    currentData = reshape(getfield(positions,fields{i}),[],1); 
    switch fields{i} 
        case 't'
            newValue = typecast(currentData,'int32');
        otherwise
            newValue = typecast(currentData,'int16');
    end
    
    % swap bytes if necessary
    if endian == 'L' 
        newValue = swapbytes(newValue);
    end
    
    % replace 1023 with NaN if desired
    if convertMissingPositionToNaN
        newValue(newValue == 1023) = NaN;
    end
    
    % store converted file as a double
    positions = setfield(positions, fields{i}, double(newValue));

end   

    
end