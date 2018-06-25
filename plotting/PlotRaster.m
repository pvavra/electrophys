function ax = PlotRaster(inputs, spikes,whichUnits)
% PlotRatser generates a simple raster-plot of the spiking activity,
% overlaying the tone and shock periods of the task
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
% Output:
%       ax         ... axes-handle object of current plot
%
% see also:
% LOADDATA
%



%-set defaults
%--------------------------------------------------------------------------
if nargin <= 2, whichUnits = 'all'; end

%-prepare input for highlight
%--------------------------------------------------------------------------
% select event of interest
[tone_timestamps, tone_durations] = GetEventsOfInterest(inputs, 'tone');
[shock_timestamps, shock_durations] = GetEventsOfInterest(inputs, 'shock');

%-figure out which cells we want to include
%--------------------------------------------------------------------------
nCells = length(spikes.timestamps);
unitsToPick = GetValidUnits(nCells, whichUnits);

%-convert timestamps to (x,y) points
%--------------------------------------------------------------------------
[xPoints, yPoints] = TimestampsToXYPoints(spikes.timestamps(unitsToPick));

%-settings for plotting
%--------------------------------------------------------------------------
% infer time-range for plotting from min/max timestamp, or set to fixed
% values: xStart = 0; xEnd = 200; in Seconds
xStart = min(xPoints(:)) - 0.05; % start half 50ms before first spike
xEnd = max(xPoints(:)) + 0.05; % end also 50ms after last spike
% make sure to not have any spikes on boundary lines (y=0 and y=max)
yStart = 0.5;
yEnd = max(yPoints) + 0.5;

% which color to show the overlay
colorTone = 'r'; 
colorShock = 'b';

%-plotting
%--------------------------------------------------------------------------
hold off
plot(xPoints,yPoints,'.k');
xlim([xStart,xEnd])
ylim([yStart, yEnd])
hold on
% add overlay for tone
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
        colorShock, 'FaceAlpha',.5, 'EdgeColor', colorShock )
end
xlabel('Time [s]')
ylabel('Cell ID')
yticks(1:length(unitsToPick))
yticklabels(unitsToPick) % pick correct unit-label based on which units have been selected for plotting

ax = gca;
