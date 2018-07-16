function spikes = LoadSpikes(filenameDataCommon, nTetrodes)

% load tetrode data
%--------------------------------------------------------------------------

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