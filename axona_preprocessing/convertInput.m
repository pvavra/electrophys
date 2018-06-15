function [timestamps, durations, event_labels] = convertInput(timestampsInput, event_types, event_bytes, mapping)
% CONVERTINPUT converts sets of timestamps (on and off events) of digital
% input events into onset-timestamps/durations-pairs.
% 
% Input: 
%       timestampsInput   ... Array. All timestamps as loaded from
%                             axona_io::read_input_file().
%
%       event_types       ... Cellarray. Elements of array are one of: 'I',
%                             'O', 'K'. Only 'I' events are processed.
%
%       event_bytes       ... Array. Byte-codes of events, reflecting which
%                             digital channels have changed state.
%
%       mapping           ... Function-handle. The mapping function should
%                             convert all available `event_bytes` into
%                             strings (i.e. their verbal description)
% 
% Output:
%       timestamps        ... Array. Timestamps of event onsets, in
%                             seconds.
%
%       durations         ... Array. Duration of events, in seconds.
%
%       event_labels      ... Cellarray. Description of each event, as
%                             obtained via @mapping.
%
% see also:
% READ_INPUT_FILE, MAPPINGINPUTS
% 



% work only on input timestamps
indicesSubset = (event_types == 'I'); 
timestampsInput = timestampsInput(indicesSubset);
event_types = event_types(indicesSubset);
event_bytes = event_bytes(indicesSubset);

% extract durations
%--------------------------------------------------------------------------

% the first event is expected to be "0", ie that no event happened yet.
assert(event_bytes(1) == 0, 'first timestamp is not "empty"');

% go through all iEvents and check when the relevant bit is turned off
% again

nUniqueEvents = 0;
timestamps = [];
durations = [];
event_labels = {};

for iTimestamp = 2:(length(event_types)-1)
    
    
    
    % first, figure out which byte changed compared to the last timestamp
    byte_change = event_bytes(iTimestamp) - event_bytes(iTimestamp -1);
    
    if byte_change > 0 % i.e. an input was turned on (else not needed: something when down, and we already took care of it)
        
        for jTimestamp = (iTimestamp+1):length(event_types)
            byte_change_next = event_bytes(jTimestamp) - event_bytes(jTimestamp - 1);
            
            % look for the next byte_change in the other direction
            if byte_change == -byte_change_next
                % collect the timestamp of onset and duration
                timestamps(end+1) = timestampsInput(iTimestamp);
                durations(end+1) = timestampsInput(jTimestamp) - timestampsInput(iTimestamp);
                if ~exist('mapping', 'var') % if no mapping provided, simply write down the byte-code as label
                    event_labels(end+1) = {byte_change};
                else
                    event_labels(end+1) = {mapping(byte_change)};
                break
            end
        end
        
        
        
        
        
        
        
        %     for jTimestamp = (iTimestamp+1):length(event_types)
        %         switch event_bytes(jTimestamp)
        %             case 0
        %                 % whether the byte was, it is gone now
        %
        %     end
    end
    
    
    
    % convert all event_bytes according to mapping
    
    
    
    
    
    end
    
    % make sure these are column vectors

    timestamps = reshape(timestamps,[], 1);
    durations = reshape(durations, [], 1);
    event_labels = reshape(event_labels, [], 1);

end