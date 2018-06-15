function [xPoints, yPoints] = TimestampsToXYPoints(timestamps)
% TimestampsToXYPoints converts a cell-array of timestamps into a set of
% (x,y)-coordinates, where x are the timepoints and y is the index of the
% respective unit (cell-array index)
% 
% Use this to convert the spike-timestamps as return from LoadData() into
% x/y coordinates for, e.g., raster plots.
% 
% Input:
%      timestamps   ... Cell-array of arrays. Each cell-array element
%                       contains the timestamps of a unit. 
%  
% Output:
%      xPoints      ... Array. Timestamp values of when spikes happened.
% 
%      yPoints      ... Array. Which unit was spiking at that time
%
% see also:
% LoadData
% 


xPoints = cell2mat(timestamps(:)); % ignore cell-structure here

% Put each cell into one row by first creating as many ones as there
% are timestamps, and then multiplying by iCell. This gives ones for
% the first cell, twos for the second cell, three for the third, etc.
for iCell = length(timestamps):-1:1
    yPointsCells{iCell} = ones(size(timestamps{iCell})) .* iCell;
end

% convert into simple array, to match xPoints
yPoints = cell2mat(yPointsCells(:));

end