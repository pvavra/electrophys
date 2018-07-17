function j = axona_channel_mapping(i, mode)
% j = axona_channel_mapping(i, mode) converts index/channel number to the other
% 
% The binary .bin data format stores the individual channels not in the
% same order as they are numbered. For example, channel 7 is stored in the
% 38th position in the data-portion of the packets. (see Dacq File Format
% for more). 
% 
% This function is essentially a look-up table and allows to reorder the
% data so that the index matches the channel number, as well as to go back
% to the order of channels as they are in the .bin file, e.g. to write out
% the data in that format.
% 
% Input: 
%      i     ... Integer. either the index or the channel
% 
%      mode  ... String. Either 'indexToChannel' or 'channelToIndex'
% 
% Output:
%       j    ... Integer. The converted index/channel. 
% 
% 
% SEE ALSO:
%  GETCHANNELDATA, WRITECHANNELDATA
% 

if nargin == 1
    mode = 'indexToChannel';
end

switch mode
    case 'channelToIndex'
        j = channelToBinIndex(i);
        
    case 'indexToChannel'
        j = indexToChannel(i);
end

end

function index = channelToBinIndex(channel)

% mapping from Dacq File Format description
indices = [...
32, 33, 34, 35, 36, 37, 38, 39,...
0, 1, 2, 3, 4, 5, 6, 7,...
40, 41, 42, 43, 44, 45, 46, 47,...
8, 9, 10, 11, 12, 13, 14, 15,...
48, 49, 50, 51, 52, 53, 54, 55,...
16, 17, 18, 19, 20, 21, 22, 23,...
56, 57, 58, 59, 60, 61, 62, 63,...
24, 25, 26, 27, 28, 29, 30, 31 ];

index = indices(channel)+1; % above matrix is for zero-indexed array

end

function channel = indexToChannel(index)
% this provides simply the inverse mapping from the above

% for i=0:63; channels(i+1) = find(indices == i); end % with indices from
% the above definition

channels = [9, 10, 11, 12, 13, 14, 15, 16, 25, 26, 27, 28, 29, 30, 31, 32, 41, 42, 43, 44, 45, 46, 47, 48, 57, 58, 59, 60, 61, 62, 63, 64, 1, 2, 3, 4, 5, 6, 7, 8, 17, 18, 19, 20, 21, 22, 23, 24, 33, 34, 35, 36, 37, 38, 39, 40, 49, 50, 51, 52, 53, 54, 55, 56];

channel = channels(index);


end

% to test that this works both ways:
% all(axona_channel_mapping(axona_channel_mapping(1:64, 'channelToIndex'),'indexToChannel')==1:64)