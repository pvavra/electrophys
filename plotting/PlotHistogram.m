function ax = PlotHistogram(inputs, spikes, whichUnits, binSize)
% PlotHistogram shows the average firing rate as a function of time
%
% In a sense, this is simply the average of a rasterplot, across units.
%
% Input:
%      inputs      ... Structure, as return by LoadData()
% 
%      spikes      ... Structure, as returned by LoadData()
% 
%      whichUnits  ... String/Array. Either 'all' or an array of integers.
%                      Indicates units for which units the plot will be
%                      generated.
% 
%      binSize     ... Integer. Indicates the desired bin-size in seconds.
% 
% Output:
%      ax          ... axes-handle of plot
%
% see also:
% LOADDATA
%





%-figure out which cells we want to include
%--------------------------------------------------------------------------
nCells = length(spikes.timestamps);
validUnits = GetValidUnits(nCells, whichUnits);

%-convert timestamps to (x,y) points
%--------------------------------------------------------------------------
[xPoints, ~] = TimestampsToXYPoints(spikes.timestamps(validUnits)); % don't need y-coordinates

%-prepare input for highlight
%--------------------------------------------------------------------------
% select event of interest
[tone_timestamps, tone_durations] = GetEventsOfInterest(inputs, 'tone');
[shock_timestamps, shock_durations] = GetEventsOfInterest(inputs, 'shock');


%-settings for plot
%--------------------------------------------------------------------------
xStart = min(xPoints(:)) - 0.05; % start half 50ms before first spike
xEnd = max(xPoints(:)) + 0.05; % end also 50ms after last spike

% calculate how many bins we'll need with the desired bin-size
nBins = ceil( (xEnd - xStart) / binSize);

% which color to show the overlay
colorTone = 'r';
colorShock = 'k';


%-plotting
%--------------------------------------------------------------------------

hold off
hist(xPoints, nBins)
hold on
% set color
h = findobj(gca,'Type','patch');
h.FaceColor = 'b';
h.EdgeColor = 'b';

ylabel('Average Firing')
xlabel('Time [s]')

% add highlight for shock & tone
% add overlay for tone
yl = ylim; yStart = yl(1); yEnd = yl(2);

for i = 1:length(tone_timestamps)
    patch(...
        [tone_timestamps(i) tone_timestamps(i)+tone_durations(i) tone_timestamps(i)+tone_durations(i) tone_timestamps(i) ],... % x-coordinates
        [yStart yStart yEnd yEnd],... % y-coordinates
        colorTone, 'FaceAlpha',.5, 'EdgeColor', colorTone )
end
% add overlay for shock
for i = 1:length(shock_timestamps)
    patch(...
        [shock_timestamps(i) shock_timestamps(i)+shock_durations(i) shock_timestamps(i)+shock_durations(i) shock_timestamps(i) ],...
        [yStart yStart yEnd yEnd], ...
        colorShock, 'FaceAlpha',.5 , 'EdgeColor', colorShock)
end

if isnumeric(whichUnits)
    title(sprintf('Selected cells: %s (binSize = %g s)', mat2str(validUnits),binSize))
else
    title(sprintf('Selected cells: %s  (binSize = %g s)',whichUnits,binSize))
end

ax = gca;


end



