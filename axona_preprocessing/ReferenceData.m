function [referencedData, referenceSignal] = ReferenceData(data, referenceChannels, mode)
% [referencedData, referenceSignal] = ReferenceData(data, referenceChannels, mode)
% Subtract a reference signal from all channels. 
% 
% Input:
%      data                 ... [channels x time] int16 array, as returned 
%                               by GetDatachannels(). 
%      referenceChannels    ... integer array. Can be a single integer
%                               (e.g. 16) or a set of integers (e.g. 1:16).
%                               These will be used as the reference
%                               channels. 
%      mode                 ... String. Either 'mean' (default) or
%                               'median'. If more than one reference
%                               channel is specified (e.g. 1:16), than this
%                               decides how the reference signal is
%                               computed - either by calculating the mean
%                               or the median across all channels. 
% Output: 
%       referencedData      ... [channels x time] int16 array - same
%                               dimensions as `data`, with the reference
%                               signal subtracted
%       referenceSignal     ... [1 x time] int16 array - the reference
%                               signal itself
% 
% SEE ALSO:
%  GETCHANNELDATA, WRITECHANNELDATA
% 


% set default `mode`
if nargin <= 2
    mode = 'mean';
end
    

% calculate reference signal 
if length(referenceChannels) > 1
    switch mode
        case 'mean'
            referenceSignal = int16(mean(data(referenceChannels,:), 1));
        case 'median'
            referenceSignal = int16(median(data(referenceChannels,:), 1));
    end
else
    referenceSignal = data(referenceChannels,:);
end

% subtract reference signal from all channels
referencedData = data - referenceSignal;
    
end