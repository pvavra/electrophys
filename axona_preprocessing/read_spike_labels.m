function [dataArray, nUnits] = read_spike_labels(filename)
% READ_SPIKE_LABELS reads spike-labels associated with spike-data
%
% This function reads in the result of the spike-sorting, where the file
% contains one integer per line (i.e. the label), with the first line
% indicating the total number of units identified.
% 
% Input: 
%     filename      ... String. Name of file which has spike labels
%
% Output:
%      dataArray    ... Integer-array, where each element represent the
%                       label of the spike (i.e. has length nSpikes)
% 
%      nUnits       ... Integer. Indicating total number of nUnit labels.
% 

fileID = fopen(filename,'r');

delimiter = {''};
formatSpec = '%f';
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
dataArray = dataArray{1}; % convert into simple array

% first element is total nr of cells found:
nUnits = dataArray(1);
% the rest is the spike-labels
dataArray = dataArray(2:end);

fclose(fileID);

end


