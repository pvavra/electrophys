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
tmax = 100; 
tmax_zoom = 5; % in seconds

smooth_scale = 10; % in Hz


%%
figure(1)
currentSamplingRate = header.sample_rate;
range = (1+tmin*currentSamplingRate) : (1+tmax*currentSamplingRate); % the 1+.. is because matlab's starting index is "1"
range_zoom = (1+tmin*currentSamplingRate) : (1+tmax_zoom*currentSamplingRate);
t = tmin:1/currentSamplingRate:tmax;
t_zoom = tmin:1/currentSamplingRate:tmax_zoom;

subplot(411)
plot(t,eeg(range),'.-')

subplot(412)
plot(t_zoom,eeg(range_zoom),'.-')

subplot(413)
plot(t_zoom,smoothdata(eeg(range_zoom), 'movmean', round(currentSamplingRate/smooth_scale)),'.-r')

subplot(414)
histogram(eeg(range), 100)


% figure two - higher sampling rate
eeg_filename2 = sprintf('%s/%s.egf', folderData, filenameDataCommon);
[header2, eeg2] = read_eeg_file(eeg_filename2);

figure(2)
currentSamplingRate = header2.sample_rate;
range = (1+tmin*currentSamplingRate) : (1+tmax*currentSamplingRate);
range_zoom = (1+tmin*currentSamplingRate) : (1+tmax_zoom*currentSamplingRate);
t = tmin:1/currentSamplingRate:tmax;
t_zoom = tmin:1/currentSamplingRate:tmax_zoom;

subplot(311)
plot(t,eeg2(range))

subplot(312)
plot(t_zoom,eeg2(range_zoom))

subplot(313)
plot(t_zoom,smoothdata(eeg2(range_zoom), 'movmean', round(currentSamplingRate/smooth_scale)),'r')

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
