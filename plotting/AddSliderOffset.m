function slider = AddSliderOffset(minT, maxT, ax, position)
% slider = AddSliderOffset(minT, maxT, ax, position) creates a UI-slider to
% control x-axis offset 
%
% Also creates a label above the slider.
%
% Input: 
%      minT      ... minimal value of offset
%
%      maxT      ... maximal value of offset
%
%      ax        ... axes-handle of plot which is being controlled
% 
%      position  ... array of 4 values [x y width height] of where to put
%                    slider
% 
% Output:
%       slider   ... ui-handle of slider object
% 
% see also:
% ADDSLIDERZOOM
%


% Create slider
slider = uicontrol('Style', 'slider',...
    'Min',minT,'Max',maxT,...
    'Value',minT,... % start at 'zero offset'
    'Position', position, ...
    'UserData',ax,... % use UserData to bind this slider to specific axes
    'String', 'offset', ...
    'Callback', @offset_x_axis);

% Add a text uicontrol to label the slider.
textOffset = 20; % put 20px above slider
uicontrol('Style','text',...
    'Position',[position(1) (position(2)+textOffset) position(3) position(4)],... 
    'String','offset');


end



function offset_x_axis(source, event, handles)
offset = source.Value;
currentAxes = source.UserData;

xlimits = xlim(currentAxes); % get current limits

% keep zoom the same, but change offset
xlim(currentAxes, [offset, offset+xlimits(2)-xlimits(1)]);
end
