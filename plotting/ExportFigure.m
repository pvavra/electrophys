function ExportFigure(filename, dpi, size)
% Set current figure dimension to 1920x1080 (fullHD) and save it to png
% file.
% 
% Inputs:
%     filename     ...String. filename under which to save current figure
% 
%     dpi          ...(optional) Integer. Resolution of figure (dots per
%                     inch). Typically, 300 (the default) is good enough to
%                     view images on screen, while 600 is a common
%                     resolution for publications
% 
%     size         ...(optional) [2x1] Vector. Specifies the size of the
%                     figure in pixels ([width height]). The default is a
%                     fullHD resolution, i.e. 1920x1080. 
% 

% set default dpi
if ~exist('dpi','var')
    dpi = 300; 
end

% set default size
if ~exist('size','var')
    size = [1920 1080]; 
end

% Make sure the output folder exists
[filepath, ~, ~] = fileparts(filename);
if ~isempty(filepath) % can be empty if file is going to be saved to current directory
    [~,~,~] = mkdir(filepath); 
end

% Make we plot the figure to desired size
set(gcf, 'Units', 'pixels'); set(gcf,'Position',[0 0 size(1) size(2)]);

% save as png file
print(sprintf('-r%i',dpi),... %  desired dpi
    filename,...
    '-dpng'... % which file-type
    );

end

