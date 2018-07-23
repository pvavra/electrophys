function inputs = LoadInputs(filename)


% load input data - same for all tetrode
%--------------------------------------------------------------------------
% First, the input file 

% add `.inp` ending to `filename`, if it is not there
[~,~,ext] = fileparts(filename); 
if ~strcmp(ext, '.bin')
    filename = sprintf('%s.inp', filename);
end

assert(exist(filename, 'file') == 2, ...
    'file "%s" not found', filename);


% read in input file
[input_header, input_timestamps, input_e_types, input_e_bytes] = read_input_file(filename);
% table(input_timestamps, input_e_types, input_e_bytes)

% convert input timestamps into 'onset/duration' format
[event_timestamp, event_duration, event_label] = convertInput(input_timestamps, input_e_types, input_e_bytes, @mappingInputs);
% table(event_timestamp, event_duration, event_label)

inputs = struct();
inputs.timestamps_onset = event_timestamp;
inputs.durations = event_duration;
inputs.labels = event_label;
inputs.headers = input_header;


end