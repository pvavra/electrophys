function [onsets, durations ] = GetEventsOfInterest(inputs, event_type)
% GetEventsOfInterest extracts the onsets and durations of an
% event-of-interest
%
% Input:
%      inputs     ... Structure. As return from LoadData().
% 
%      event_type ... String. One of the following events-of-interests:
%                     tone, shock, trace, baseline.
% 
% Output:
%      onsets:    ... Array. Timestamps of onsets of event-of-interst.
% 
%      durations  ... Array. Duration of event-of-interest.
%
% see also:
%  LOADDATA
%





tone_label = 'on: tone'; % based on 'mappingInputs.m'

switch event_type
    
    case 'tone'
        % pick all onsets timestamps and durations of this event-type:
        target_events = strcmp(inputs.labels,tone_label);
        onsets = inputs.timestamps_onset(target_events);
        durations = inputs.durations(target_events);
        
    case 'shock'
        % define the shock as being 20s after tone, with a duration of 1
        % second
        %
        % Note: This will be handled via another input event in the future,
        % but for this dataset, the shock was not logged by the axona
        % system
        target_events = strcmp(inputs.labels,tone_label);
        tone_timestamps = inputs.timestamps_onset(target_events);
        tone_durations = inputs.durations(target_events);
        
        onsets = tone_timestamps + tone_durations + 20;
        durations = ones(size(onsets));
        
    case 'trace'
        % trace period is defined as 'after tone and before shock' 
        % 
        % since there are no dedicated input timestamps for this, we infer
        % it the info from the tone timestamps & durations
        target_events = strcmp(inputs.labels,tone_label);
        tone_timestamps = inputs.timestamps_onset(target_events);
        tone_durations = inputs.durations(target_events);
        
        onsets = tone_timestamps + tone_durations; % tone offset
        durations = ones(size(onsets)) * 20; % duration is twenty seconds after tone offset
        
    case 'baseline'
        % define baseline periods
        % current definition: 20 seconds before the onset of the tone
        
        % first, figure out when the tone started:
        % pick all timestamps and durations of this event-type:
        target_events = strcmp(inputs.labels,tone_label);
        tone_timestamps = inputs.timestamps_onset(target_events);
        % second: infer baseline onsets and durations
        onsets = tone_timestamps - 20;
        durations = 20 .* ones(size(onsets));
        
    otherwise
        error('unknown event_type')
end

end