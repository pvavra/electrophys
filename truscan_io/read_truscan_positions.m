function   [positions, header] = read_truscan_positions(filename)

assert(exist(filename, 'file') == 2, 'File %s not found', filename);

% DEFINE SAMPLING FREQUENCY
SAMPLING_FREQUENCY = 4;


% Based on auto-generated script by MATLAB 
%% Import the data
[~, ~, raw] = xlsread(filename,'Sheet1');
raw = raw(2:end,:);
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
stringVectors = string(raw(:,[1,13]));
stringVectors(ismissing(stringVectors)) = '';
raw = raw(:,[2,3,4,5,6,7,8,9,10,11,12]);
% 
% %% Replace non-numeric cells with NaN
% R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
% raw(R) = {NaN}; % Replace non-numeric cells



%% Create output variable
data = reshape([raw{:}],size(raw));

%% Create table
positions = table;

% create header structure
header = struct();

%% Allocate imported array to column variable names
header.Project_ID = unique(categorical(stringVectors(:,1)));
header.Session_Number = unique(data(:,1));
header.Station_Number = unique(data(:,2));
header.nx = unique(data(:,10));
header.ny = unique(data(:,11));
header.Run_Number = unique(data(:,3));
header.Protocol_ID = unique(data(:,4));
header.zx = unique(data(:,8));
header.zy = unique(data(:,9));


positions.Time = data(:,5) / SAMPLING_FREQUENCY; % scale to seconds, instead of samples
positions.x = data(:,6);
positions.y = data(:,7);
positions.stimuli = stringVectors(:,2);






end

