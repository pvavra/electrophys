% this script shows how to load and display position data

%% Setup
% expand the path
addpath('axona_io')
addpath('plotting')

folderData = '/data/fred_old/Dataset Mouse 304/Converted no Ref';
filenameDataCommon = '304D1TFC';
filenameDataCommon = sprintf('%s/%s', folderData, filenameDataCommon); % convert to full-path version

% define how to call the new file, and where to put it
folderOutput = folderData; % put resulting file in the same as the original data


% Specify whether to save figures to file. If yes, the next variables need
% to be set as well. NOTE: any existing images will be overwritten without
% a warning!
saveFigures = true; % yes/no on whether to save figures to file.
% if figures should be saved, specify the folder where to put them
folderOutput = '/data/fred_old/Dataset Mouse 304/results';
% define which resolution (dot-per-inch) to use. 300 is good for on-screen
% viewing, while 600 is good for (most) publications
dpi = 300;


%% Load Position data
[data_position, header_position] = read_pos_file(filenameDataCommon, true);


%% plot position data x1/y1
x = data_position.x1;
y = data_position.y1; 
label_x = 'x1';
label_y = 'y1';

PlotPositionScatter(x,y,label_x,label_y, 1);
set(gcf, 'Name', 'First position data')

% save figure to file
if saveFigures
    filename = sprintf('%s/positionData_Axona_x1y1', folderOutput);
    ExportFigure(filename, dpi);
end



%% plot position data x1/y1 -- for the first 100 samples
subset = 1:1000; 
x = data_position.x1(subset);
y = data_position.y1(subset); 
label_x = 'x1';
label_y = 'y1';
PlotPositionScatter(x,y,label_x,label_y, 2);
set(gcf, 'Name', 'First position data -- subset')

% save figure to file
if saveFigures
    filename = sprintf('%s/positionData_Axona_x1y1_first1000samples', folderOutput);
    ExportFigure(filename, dpi);
end


%% plot position data x1/y1 -- with all (0,0) positions removed
subset = 1:1000; 
x = data_position.x1(subset);
y = data_position.y1(subset); 
label_x = 'x1';
label_y = 'y1';
indices_00 = (x == 0 & y == 0);
x = x(~indices_00); y = y(~indices_00);
PlotPositionScatter(x,y,label_x,label_y, 3);
set(gcf, 'Name', 'First position data -- subset with (0,0) removed')

% save figure to file
if saveFigures
    filename = sprintf('%s/positionData_Axona_x1y1_zeroZeroRemoved', folderOutput);
    ExportFigure(filename, dpi);
end


%% plot position data x2/y2
x = data_position.x2;
y = data_position.y2; 
label_x = 'x2';
label_y = 'y2';

PlotPositionScatter(x,y,label_x,label_y, 4);
% save figure to file
if saveFigures
    filename = sprintf('%s/positionData_Axona_x2y2', folderOutput);
    ExportFigure(filename, dpi);
end


%% plot number of pixels timeseries
figure(5);
set(gcf, 'Name', 'Number of Pixels')
subplot(311)
plot(data_position.numpix1,'.')

subplot(312)
plot(data_position.numpix2,'.')

subplot(313)
plot(data_position.totalpix,'.')

% save figure to file
if saveFigures
    filename = sprintf('%s/positionData_Axona_numberOfPixels', folderOutput);
    ExportFigure(filename, dpi);
end
