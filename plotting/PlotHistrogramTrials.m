function ax = PlotHistogramTrials(inputs, spikes,whichUnit,binSize)
% PlotHistogramTrials generates a simple raster-plot of the spiking activity
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
%      binSize     ... Double. Bin-size for histogram in seconds
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

xPoints = NaN(size(timestamps));
for iPoint = 1:length(timestamps)
    
    % check whether current timestamp is inside of period-of interest
    for iPeriod = 1:length(periodOfInterestOnsets)
        if timestamps(iPoint) >= periodOfInterestOnsets(iPeriod) && ...
                timestamps(iPoint) <= periodOfInterestOffsets(iPeriod)
            
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

% which color to show the overlay
colorTone = 'r';
colorShock = 'b';
colorHistogram = 'k';

nBins = ceil( (xEnd - xStart) / binSize);

%-plotting
%--------------------------------------------------------------------------
hold off
hist(xPoints, nBins);
h = findobj(gca,'Type','patch');
h.FaceColor = colorHistogram;
h.EdgeColor = colorHistogram;

hold on
% add overlay for tone
xlim([xStart,xEnd])
yl = ylim; yStart = yl(1); yEnd = yl(2);

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
ylabel(sprintf('Average Firing\n[spikes/bin]'))

title(sprintf('Cell ID: %i (binSize = %g s)',whichUnit, binSize));


ax = gca;
