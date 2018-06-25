function ax = PlotRasterTrials(inputs, spikes,whichUnit)
% PlotRatserTrials generates a simple raster-plot of the spiking activity
% of a single unit (i.e. cell), where the y-axis are the repetitions of the
% task and overlaying the tone and shock periods of the task.
%
% A trial is defined as starting 20s prior to the tone-onset, and as ending
% 20s after the shock-offset.
%
% Input:
%      inputs      ... Structure, as return by LoadData()
%
%      spikes      ... Structure, as returned by LoadData()
%
%      whichUnit   ... Integer. Indicates units for which units the plot
%                      will be generated.
%
% Output:
%       ax         ... axes-handle object of current plot
%
% see also:
% LOADDATA
%


%-prepare input for highlight
%--------------------------------------------------------------------------
% select event of interest
[tone_timestamps, tone_durations] = GetEventsOfInterest(inputs, 'tone');
[shock_timestamps, shock_durations] = GetEventsOfInterest(inputs, 'shock');

%-define periods of interest
%--------------------------------------------------------------------------
periodOfInterestOnsets = tone_timestamps - 20;
periodOfInterestOffsets = shock_timestamps + shock_durations + 20;

%-figure out which cells we want to include
%--------------------------------------------------------------------------
nCells = length(spikes.timestamps);
unitsToPick = GetValidUnits(nCells, whichUnit);

%-convert timestamps to (x,y) points
%--------------------------------------------------------------------------
timestamps = cell2mat(spikes.timestamps(unitsToPick));

yPoints = NaN(size(timestamps)); % preallocate w/ nan
xPoints = NaN(size(timestamps));
for iPoint = 1:length(timestamps)
    
    % check whether current timestamp is inside of period-of interest
    for iPeriod = 1:length(periodOfInterestOnsets)
        if timestamps(iPoint) >= periodOfInterestOnsets(iPeriod) && ...
                timestamps(iPoint) <= periodOfInterestOffsets(iPeriod)
            % if it is, define x/y points
            
            % y-points are based on trial number.
            yPoints(iPoint) = iPeriod;
            
            % x-points are now relative to the trial onset
            xPoints(iPoint) = timestamps(iPoint) - periodOfInterestOnsets(iPeriod);
        end
    end
end



%-settings for plotting
%--------------------------------------------------------------------------
% infer time-range for plotting from min/max timestamp, or set to fixed
% values: xStart = 0; xEnd = 200; in Seconds
xStart = min(xPoints(:)) - 0.05; % start half 50ms before first spike
xEnd = max(xPoints(:)) + 0.05; % end also 50ms after last spike
% make sure to not have any spikes on boundary lines (y=0 and y=max)
yStart = min(yPoints) -0.5;
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
i = 1;
patch(...
    [tone_timestamps(i)-periodOfInterestOnsets(i) tone_timestamps(i)+tone_durations(i)-periodOfInterestOnsets(i) tone_timestamps(i)+tone_durations(i)-periodOfInterestOnsets(i) tone_timestamps(i)-periodOfInterestOnsets(i) ],... % x-coordinates
    [yStart yStart yEnd yEnd],... % y-coordinates
    colorTone, 'FaceAlpha',.5, 'EdgeColor', colorTone )

% add overlay for shock

patch(...
    [shock_timestamps(i)-periodOfInterestOnsets(i) shock_timestamps(i)+shock_durations(i)-periodOfInterestOnsets(i) shock_timestamps(i)+shock_durations(i)-periodOfInterestOnsets(i) shock_timestamps(i)-periodOfInterestOnsets(i) ],...
    [yStart yStart yEnd yEnd], ...
    colorShock, 'FaceAlpha',.5, 'EdgeColor', colorShock )

xlabel('Time [s]')
ylabel('Trial Number')
yticks(1:length(periodOfInterestOnsets))
title(sprintf('Cell ID: %i',whichUnit))
% yticklabels(unitsToPick) % pick correct unit-label based on which units have been selected for plotting

ax = gca;
