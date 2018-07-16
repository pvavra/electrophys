function [inputs,spikes] = LoadData(filenameDataCommon,nTetrodes)
% LOADDATA Loads Axona data files, using the axona_io library
%
% For analysis, this function converts the "raw" data as loaded by the
% `axona_io` functions and converts them into more usable structures. If
% `spikes` is not requested as output, loading tetrode data is skipped.
%
% Requires:
%    `axona_io` library (basic I/O for native axona files)
%    `axona_preprocessing` library (for transforming the axona output into
%                                   more usable form)
%     Spike-sorting already done
%
%  Input:
%     filenameDataCommon  ... String. Fullpath (i.e. with full directory
%                             path) of the common filename of all files
%                             related to spiking data (typically everything
%                             except the file ending).
%
%     nTetrodes           ... Integer. Number of Tetrode files available.
%                             All will be loaded.
%
%  Output:
%     inputs              ... Structure, containing the following fields:
%                             header, timestamps_onset, durations, labels.
%                             Header itself is a structure (see
%                             read_input_file.m in `axona_io` library). the
%                             event labels are taken from 'mappingInputs.m'
%
%     spikes              ... [optional] Structure-array, containting
%                             following fields: header, timestamps,
%                             waveforms. The length of the array is
%                             `nTetrodes`.
%
% see also:
%   READ_INPUT_FILE, READ_TETRODE_FILE


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


% load tetrode data
%--------------------------------------------------------------------------
if nargout == 2
    for iTetrode = nTetrodes:-1:1
        % next, for the timestamps of spikes & waveforms
        filenamesSpikes{iTetrode} = sprintf('%s.%i', ...
            filenameDataCommon, ...
            iTetrode);
        assert(exist(filenamesSpikes{iTetrode}, 'file') == 2, ...
            'file "%s" not found', filenamesSpikes{iTetrode});
        % and also, for the spike-labels from the cluster cutting
        filenamesSpikeLabels{iTetrode} = sprintf('%s.clu.%i', ...
            filenameDataCommon,...
            iTetrode);
        assert(exist(filenamesSpikeLabels{iTetrode}, 'file') == 2, ...
            'file "%s" not found', filenamesSpikeLabels{iTetrode});
    end
    
    
    % and for each tetrode:
    spikes = struct();
    
    
    for iTetrode = nTetrodes:-1:1
        %-load all timestamps
        %------------------------------------------------------------------
        [header, timestamps, waveforms] = read_tetrode_file(filenamesSpikes{iTetrode});
        
        % if using tetrodes for each channel, we expect the timestamps to be
        % identical for all channels within the tetrode, so we can collapse
        % this 4-channel timestamp array to a single vector
        assert(size(unique(timestamps','rows'), 1) == 1,...
            'channels within tetrode have different timestamps (%s)', ...
            filenamesSpikes{iTetrode});
        timestamps = timestamps(:,1);
        
        % load the associated spike-sorting file
        %------------------------------------------------------------------
        cell_labels = read_spike_labels(filenamesSpikeLabels{iTetrode});
        %     assert(length(cell_labels) == length(timestamps), ...
        %         'Number of cell labels (from spike sorting) does not match number of timestamps!');
        if (length(cell_labels) ~= length(timestamps))
            fprintf(['WARNING: Tetrode %i data is inconistent\n '...
                'nCellLabels = %i\tnTimestamps = %i\n' ...
                'ARBITRARILY removing the trailing timestamps/cell-labels to create a matching set.\n'...
                'THIS NEEDS TO BE FIXED IN THE INPUT DATA.\n\n'],...
                iTetrode, ...
                length(cell_labels), ...
                length(timestamps));
            
            nToSelect = min(length(cell_labels),length(timestamps));
            cell_labels = cell_labels(1:nToSelect); % THIS STEP IS ARBITRARY!!!
            timestamps = timestamps(1:nToSelect);
        end
        
        %- reshape data - one vector per cell
        % Sort timestamps into as many vectors as there are cells
        %------------------------------------------------------------------
        nCells = max(cell_labels);
        for iCell = nCells:-1:1
            % use logical indexing with cell_label == iCell to select subset of
            % timestamps associated with current cell
            data{iCell} = timestamps(cell_labels == iCell);
        end
        
        % store it
        spikes(iTetrode).timestamps = data;
        spikes(iTetrode).waveforms = waveforms;
        spikes(iTetrode).headers = header;
        
    end
    
end



end

