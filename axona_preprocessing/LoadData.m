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


inputs = LoadInputs(filenameDataCommon);


spikes = LoadSpikes(filenameDataCommon, nTetrodes);



end

