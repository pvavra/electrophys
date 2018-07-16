function inputs = LoadInputs(filenameDataCommon)


% load input data - same for all tetrode
%--------------------------------------------------------------------------
% First, the input file - Note: only one file for all tetrodes,
% so no `iTetrode` index here
filenamesInputFile = sprintf('%s.inp', filenameDataCommon);
assert(exist(filenamesInputFile, 'file') == 2, ...
    'file "%s" not found', filenamesInputFile);


% read in input file
[input_header, input_timestamps, input_e_types, input_e_bytes] = read_input_file(filenamesInputFile);
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