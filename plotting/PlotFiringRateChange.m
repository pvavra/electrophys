function PlotFiringRateChange(inputs, spikes, event_type, whichUnits, average)
% PlotFiringRateChange for a event-of-interest, plot the change in firing
% rate, in combarison to baseline. If 'baseline' is requested, it shows the
% simply the baseline firing rate
% 
% Input:
%      inputs      ... structure, contains info on input timestamps as
%                      return by LoadData().
% 
%      spikes      ... structure, contains info on spikes. To use the
%                      output of LoadData(), subset for a single tetrode
%                      (e.g. `spikes(1)`)
%
%      event_type  ... String. Label of event-of-interest. See
%                      GetEventsOfInterest() so see a list valid
%                      event-labels.
%      whichUnits  ... String/Array. Either 'all' or an array of integers.
%                      Indicates units for which units the plot will be
%                      generated
% 
%      average     ... Boolean. Whether to average for across repetitions
%                      of the event of interest. If yes, will plot standard
%                      errors. Default: true
% 
% see also:
% LOADDATA, GETEVENTSOFINTEREST 
%




% set defaults
%--------------------------------------------------------------------------
if nargin <= 4, average = 1; end % average across events per default

% select event of interest: onsets and durations
%--------------------------------------------------------------------------
[event_starts, event_durations] = GetEventsOfInterest(inputs, event_type);
event_ends = event_starts + event_durations;

[baseline_starts, baseline_durations] = GetEventsOfInterest(inputs, 'baseline');
baseline_ends = baseline_starts + baseline_durations;

%-figure out which cells we want to include
%--------------------------------------------------------------------------
nCells = length(spikes.timestamps);
unitsToPick = GetValidUnits(nCells, whichUnits);


% calculate mean firing rates for baseline and event
%----------------------------------------------------------------------
% first caculate it for each event

for iEvent = length(event_starts):-1:1
    % sum how many spikes happened within each event period, for each cell
    % separately
    for iCell=1:length(unitsToPick)
        timestampsOfCurrentCell = spikes.timestamps{unitsToPick(iCell)};
        % calculate for event period
        nSpikesEvent(iEvent,iCell) = sum(...
            timestampsOfCurrentCell > event_starts(iEvent) ...
            & timestampsOfCurrentCell < event_ends(iEvent) ...
            );
        % calculate for baseline
        nSpikesBaseline(iEvent,iCell) = sum(...
            timestampsOfCurrentCell > baseline_starts(iEvent) ...
            & timestampsOfCurrentCell < baseline_ends(iEvent)...
            );
    end
    
    % convert nEvents into firing rate by normalizing w/ duration
    nSpikesEvent(iEvent,:) = nSpikesEvent(iEvent,:) ./ event_durations(iEvent);
    nSpikesBaseline(iEvent,: ) = nSpikesBaseline(iEvent,:) ./ baseline_durations(iEvent);
end

if strcmp(event_type, 'baseline')
    % if only baseline requested, set firing rate to baseline
    firingRate = nSpikesBaseline;
    yLabelString = 'Firing Rate [Hz]'; % define correct y-axis label
else
    firingRate = nSpikesEvent - nSpikesBaseline;
    yLabelString = 'Firing Rate Change [Hz]'; % define correct y-axis label
end

if average % calculate mean across traces only if required
    meanFiringRate = mean(firingRate,1);
    semFiringRate = std(firingRate,0,1) ./ sqrt(length(event_starts));
end


% plotting
%--------------------------------------------------------------------------
hold off



if average
    barwitherr(semFiringRate, meanFiringRate)
    xlabel('Cell ID')
    xticklabels(cellstr(num2str(unitsToPick')))
    title(sprintf('Event: %s', event_type))
else
    bar(firingRate)
    xlabel('Event Occurrence')
    legend(cellfun(@(x) sprintf('Cell ID %s',x), cellstr(num2str(unitsToPick')), 'UniformOutput', 0),...
        'Location','northwest')
end

ylabel(yLabelString)
if isnumeric(whichUnits)
    title(sprintf('Event: %s - Selected Cells: %s',event_type, mat2str(unitsToPick)))
else
    title(sprintf('Event: %s - Selected Cells: %s',event_type, whichUnits))
end

end