addpath('../axona_io')
addpath('axona_preprocessing')
addpath('libs/barwitherr') % for plotting errorbars on top of bar-plots
addpath('plotting')
% 
% folderData = '/home/petvav/ownCloud/Documents/projects/fred/matlab_scripts_for_fred/data';
% % how are the files called - provide the part which is shared among them
% filenameDataCommon = '1.8HP1.0LP55.1_modified';

% folderData = '/data/fred/Conditioning Data Full with inp/304D1TFC Converted Spikes EEG';
% filenameDataCommon = '304D1TFC Converted Spikes';

folderData = '/data/fred/Dataset Mouse 304/Converted no Ref';
filenameDataCommon = '304D1TFC';


% number of channels, i.e. files ending in .1, .2, etc., up-to nChannels
nTetrodes = 4;


eeg_filename = sprintf('%s/%s.eeg', folderData, filenameDataCommon);
[header, eeg] = read_eeg_file(eeg_filename);

eeg_filename2 = sprintf('%s/%s.egf', folderData, filenameDataCommon);
[header2, eeg2] = read_eeg_file(eeg_filename2);

tmin = 0; % in seconds
tmax = 400; 
tmax_zoom = 5; % in seconds

smooth_scale = 25; % in Hz


%%
figure(1)
currentSamplingRate = header.sample_rate;
range = (1+tmin*currentSamplingRate) : (1+tmax*currentSamplingRate); % the 1+.. is because matlab's starting index is "1"
range_zoom = (1+tmin*currentSamplingRate) : (1+tmax_zoom*currentSamplingRate);
t = tmin:1/currentSamplingRate:tmax;
t_zoom = tmin:1/currentSamplingRate:tmax_zoom;

subplot(411)
plot(t,eeg(range),'.-')
title('eeg file')

subplot(412)
windowSize = round(currentSamplingRate/smooth_scale);
hold off
plot(t_zoom,eeg(range_zoom),'.-', 'DisplayName','data')
hold on
plot(t_zoom,smoothdata(eeg(range_zoom), 'movmean', windowSize),'.-r', 'DisplayName',sprintf('moving mean (windowSize = %g)',windowSize));
title('eeg file - zoomed in')
legend

subplot(413)
plot(t_zoom,smoothdata(eeg(range_zoom), 'movmean', windowSize),'.-r', 'DisplayName',sprintf('moving mean (windowSize = %g)',windowSize));
title('eeg file - zoom in - moving average only')


subplot(414)
hold off
histogram(eeg(range), -130:5:130)
hold on
% add overlays for outside of the valid range
colorOutside = 'r';
yl = ylim; yStart = yl(1); yEnd = yl(2);
xl = xlim; xLeftEdge = xl(1); xRightEdge = xl(2);
% left patch
patch([xLeftEdge -128 -128 xLeftEdge], [yStart yStart yEnd yEnd], colorOutside, 'FaceAlpha',.5,'EdgeColor',colorOutside);
patch([xRightEdge 128 128 xRightEdge], [yStart yStart yEnd yEnd], colorOutside, 'FaceAlpha',.5,'EdgeColor',colorOutside);

title('values in eeg-file')



% figure two - higher sampling rate
eeg_filename2 = sprintf('%s/%s.egf', folderData, filenameDataCommon);
[header2, eeg2] = read_eeg_file(eeg_filename2);

figure(2)
currentSamplingRate = header2.sample_rate;
range = (1+tmin*currentSamplingRate) : (1+tmax*currentSamplingRate);
range_zoom = (1+tmin*currentSamplingRate) : (1+tmax_zoom*currentSamplingRate);
t = tmin:1/currentSamplingRate:tmax;
t_zoom = tmin:1/currentSamplingRate:tmax_zoom;

subplot(411)
plot(t,eeg2(range))

subplot(412)
plot(t_zoom,eeg2(range_zoom))

subplot(413)
plot(t_zoom,smoothdata(eeg2(range_zoom), 'movmean', round(currentSamplingRate/smooth_scale)),'r')

subplot(414)
hold off
histogram(eeg2,-(2^16/2+10):100:(2^16/2+10))
hold on
% add overlays for outside of the valid range
colorOutside = 'r';
yl = ylim; yStart = yl(1); yEnd = yl(2);
xl = xlim; xLeftEdge = xl(1); xRightEdge = xl(2);
% left patch
patch([xLeftEdge -2^16/2 -2^16/2 xLeftEdge], [yStart yStart yEnd yEnd], colorOutside, 'FaceAlpha',.5,'EdgeColor',colorOutside);
patch([xRightEdge 2^16/2 2^16/2 xRightEdge], [yStart yStart yEnd yEnd], colorOutside, 'FaceAlpha',.5,'EdgeColor',colorOutside);

%% 
figure(3)
subplot(211)
hold off
currentSamplingRate = header.sample_rate;
range = (1+tmin*currentSamplingRate) : (1+tmax*currentSamplingRate); % the 1+.. is because matlab's starting index is "1"
range_zoom = (1+tmin*currentSamplingRate) : (1+tmax_zoom*currentSamplingRate);
t = tmin:1/currentSamplingRate:tmax;
t_zoom = tmin:1/currentSamplingRate:tmax_zoom;
eeg_smoothed = smoothdata(eeg(range_zoom), 'movmean', round(currentSamplingRate/smooth_scale));
eeg_smoothed = eeg_smoothed ./ std(eeg_smoothed);
plot(t_zoom,eeg_smoothed,'b')
hold on

currentSamplingRate = header2.sample_rate;
range = (1+tmin*currentSamplingRate) : (1+tmax*currentSamplingRate); % the 1+.. is because matlab's starting index is "1"
range_zoom = (1+tmin*currentSamplingRate) : (1+tmax_zoom*currentSamplingRate);
t = tmin:1/currentSamplingRate:tmax;
t_zoom = tmin:1/currentSamplingRate:tmax_zoom;
eeg_smoothed2 = smoothdata(eeg2(range_zoom), 'movmean', round(currentSamplingRate/smooth_scale));
eeg_smoothed2 = eeg_smoothed2 ./ std(eeg_smoothed2);
plot(t_zoom,eeg_smoothed2,'r')

%% 
% [spec, freqoi, timeoi] = ft_specest_wavelet(eeg2(range_zoom)', t_zoom);
