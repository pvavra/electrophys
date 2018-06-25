function slider = AddSliderZoom(minT, maxT, ax, position)
% slider = AddSliderZoom(minT, maxT, ax, position) creates a UI-slider to
% control x-axis zoom
%
% Also creates a label above the slider.
%
% This effectively controls the range of displayed values, where the
% minimal range is 10 miliseconds, and the maximal range is maxT-minT (i.e.
% all data).
%
% Input: 
%      minT      ... minimal value of x-axis values
%
%      maxT      ... maximal value of x-axis values
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
% ADDSLIDEROFFSET
%


slider = uicontrol('Style', 'slider',...
    'Min',0.01,'Max',maxT-minT,... % minimal range is 0.01 seconds
    'Value',maxT-minT,... % start at completely zoomed-out
    'Position', position,...
    'UserData',ax, ... % use UserData to bind slider to specific axes
    'String','Zoom',...
    'Callback', @zoom_x_axis);

% Add a text uicontrol to label the slider.
uicontrol('Style','text',...
    'Position',[position(1) position(2)+20 position(3) position(4)],... % put 20px above slider
    'String','range');


end


function zoom_x_axis(source, event)
new_range= source.Value;
currentAxes = source.UserData;
xlimits = xlim(currentAxes); 

xlim(currentAxes,[xlimits(1), xlimits(1) + new_range]);

end