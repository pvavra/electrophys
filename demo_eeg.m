% This script demonstrates how to plot info on the LFP data 


%% Setup & Initialization
%==========================================================================

addpath('axona_io')
addpath('axona_preprocessing')
addpath('libs/barwitherr') % for plotting errorbars on top of bar-plots
addpath('plotting')
addpath('lfp')
% 
% folderData = '/home/petvav/ownCloud/Documents/projects/fred/matlab_scripts_for_fred/data';
% % how are the files called - provide the part which is shared among them
% filenameDataCommon = '1.8HP1.0LP55.1_modified';

% folderData = '/data/fred/Conditioning Data Full with inp/304D1TFC Converted Spikes EEG';
% filenameDataCommon = '304D1TFC Converted Spikes';

folderData = '/data/fred_old/Dataset Mouse 304/Converted no Ref';
filenameDataCommon = '304D1TFC';

% number of channels, i.e. files ending in .1, .2, etc., up-to nChannels
nTetrodes = 4;

eeg_filename = sprintf('%s/%s.eeg', folderData, filenameDataCommon);
[header, eeg] = read_eeg_file(eeg_filename);

eeg_filename_large = sprintf('%s/%s.egf', folderData, filenameDataCommon);
[header_large, eeg_large] = read_eeg_file(eeg_filename_large);

tmin = 0; % in seconds
tmax = 400; 
tmax_zoom = 5; % in seconds

smooth_scale = 25; % in Hz


% Specify whether to save figures to file. If yes, the next variables need
% to be set as well. NOTE: any existing images will be overwritten without
% a warning!
saveFigures = true; % yes/no on whether to save figures to file.
% if figures should be saved, specify the folder where to put them
folderOutput = '/data/fred_old/Dataset Mouse 304/results';
% define which resolution (dot-per-inch) to use. 300 is good for on-screen
% viewing, while 600 is good for (most) publications
dpi = 300;


%% figure 1: .eeg file
%==========================================================================
figure(1)
set(gcf, 'Name','.eeg File (250Hz sampling frequency)')
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

% save figure to file
if saveFigures
    filename = sprintf('%s/eeg_overview', folderOutput);
    ExportFigure(filename, dpi);
end


%% figure 2: .egf file
%==========================================================================
figure(2)
set(gcf, 'Name','.eeg File (4.8kHz sampling frequency)')

currentSamplingRate = header_large.sample_rate;
range = (1+tmin*currentSamplingRate) : (1+tmax*currentSamplingRate);
range_zoom = (1+tmin*currentSamplingRate) : (1+tmax_zoom*currentSamplingRate);
t = tmin:1/currentSamplingRate:tmax;
t_zoom = tmin:1/currentSamplingRate:tmax_zoom;

subplot(411)
plot(t,eeg_large(range))

subplot(412)
plot(t_zoom,eeg_large(range_zoom))

subplot(413)
plot(t_zoom,smoothdata(eeg_large(range_zoom), 'movmean', round(currentSamplingRate/smooth_scale)),'r')

subplot(414)
hold off
histogram(eeg_large,-(2^16/2+10):100:(2^16/2+10))
hold on
% add overlays for outside of the valid range
colorOutside = 'r';
yl = ylim; yStart = yl(1); yEnd = yl(2);
xl = xlim; xLeftEdge = xl(1); xRightEdge = xl(2);
% left patch
patch([xLeftEdge -2^16/2 -2^16/2 xLeftEdge], [yStart yStart yEnd yEnd], colorOutside, 'FaceAlpha',.5,'EdgeColor',colorOutside);
patch([xRightEdge 2^16/2 2^16/2 xRightEdge], [yStart yStart yEnd yEnd], colorOutside, 'FaceAlpha',.5,'EdgeColor',colorOutside);

% save figure to file
if saveFigures
    filename = sprintf('%s/egf_overview', folderOutput);
    ExportFigure(filename, dpi);
end


%% figure 3: overlap of the two signal
%==========================================================================
figure(3)
set(gcf, 'Name','overlap of .eeg and .egf data (first couple of seconds)')
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

currentSamplingRate = header_large.sample_rate;
range = (1+tmin*currentSamplingRate) : (1+tmax*currentSamplingRate); % the 1+.. is because matlab's starting index is "1"
range_zoom = (1+tmin*currentSamplingRate) : (1+tmax_zoom*currentSamplingRate);
t = tmin:1/currentSamplingRate:tmax;
t_zoom = tmin:1/currentSamplingRate:tmax_zoom;
eeg_smoothed2 = smoothdata(eeg_large(range_zoom), 'movmean', round(currentSamplingRate/smooth_scale));
eeg_smoothed2 = eeg_smoothed2 ./ std(eeg_smoothed2);
plot(t_zoom,eeg_smoothed2,'r')

% save figure to file
if saveFigures
    filename = sprintf('%s/comparison_eeg_egf', folderOutput);
    ExportFigure(filename, dpi);
end


%% figure 4: power spectra
%==========================================================================
L = length(eeg);
spectrum = PowerSpectrum(eeg);
frequencies = header.sample_rate * (0:(L/2))/L; % infer which frequencies are possible

L = length(eeg_large);
spectrum_large = PowerSpectrum(eeg_large);
frequencies_large = header_large.sample_rate * (0:(L/2))/L; %


figure(4)
set(gcf, 'Name','Power spectra of .eeg and .egf data')

% power spectrum of '.eeg' file
subplot(411)
hold off
plot(frequencies, spectrum/max(spectrum))
xlabel('frequency [Hz]')
ylabel('normalized power')
title('full power spectrum of `.eeg` file')

% power spectrum of '.egf' file
subplot(412)
hold off
plot(frequencies_large, spectrum_large)
title('full power spectrum of `.egf` file')
xlabel('frequency [Hz]')
ylabel('normalized power')


% power spectrum of .eeg file for frequency range of interest
subplot(413)
freq_boundaries = [0 20];
hold off
indices_selection = frequencies > freq_boundaries(1) & frequencies < freq_boundaries(2);
plot(frequencies(indices_selection), spectrum(indices_selection)/max(spectrum(indices_selection)), 'DisplayName','.eeg data')
title(sprintf('Power spectrum for range %g to %g Hz - .eeg file', freq_boundaries(1), freq_boundaries(2)))

% power spectrum of .eeg file for frequency range of interest
subplot(414)
freq_boundaries = [0 20];
hold off
indices_selection = frequencies_large > freq_boundaries(1) & frequencies_large < freq_boundaries(2);
plot(frequencies_large(indices_selection), spectrum_large(indices_selection)/max(spectrum_large(indices_selection)), 'DisplayName','.egf data')
title(sprintf('Power spectrum for range %g to %g Hz - .egf file', freq_boundaries(1), freq_boundaries(2)))

% save figure to file
if saveFigures
    filename = sprintf('%s/powerspectra_fft', folderOutput);
    ExportFigure(filename, dpi);
end


%% calculate time-frequency spectra for fig 5
%==========================================================================

% using wavelet convolution
frequecies_of_interest = 1:100;
nCycles_in_wavelet = 20;
tic
[tf_power, tf_phase] = TF_wavelets(eeg, frequecies_of_interest, nCycles_in_wavelet, header.sample_rate);
toc
tic
[tf_power_large, tf_phase_large] = TF_wavelets(eeg_large, frequecies_of_interest, nCycles_in_wavelet, header_large.sample_rate);
toc


%% figure 5: plot time-freuqncy spectra
%==========================================================================

figure(5)
subplot(311)
hold off
imagesc(tf_power' ./ mean(tf_power',1))
axis xy
xlabel('time [s]')
timeTicks = 0:100:length(eeg)/header.sample_rate; % i.e. 0:100:tmax
set(gca, 'XTick',timeTicks*header.sample_rate)
set(gca, 'XTickLabel', num2str(timeTicks'))
ylabel('Power [normalized to mean]')
title('power spectrum of .eeg file')

subplot(312)
hold off
imagesc(tf_power_large' ./ mean(tf_power_large',1))
axis xy
xlabel('time [s]')
timeTicks = 0:100:length(eeg_large)/header_large.sample_rate; % i.e. 0:100:tmax
set(gca, 'XTick',timeTicks*header_large.sample_rate)
set(gca, 'XTickLabel', num2str(timeTicks'))
ylabel('Power [normalized to mean]')
title('power spectrum of .egf file')

subplot(313)
hold off
imagesc(log(tf_power' ./ mean(tf_power',1)))
axis xy
xlabel('time [s]')
timeTicks = 0:100:length(eeg)/header.sample_rate; % i.e. 0:100:tmax
set(gca, 'XTick',timeTicks*header.sample_rate)
set(gca, 'XTickLabel', num2str(timeTicks'))
ylabel('Power [normalized to mean]')
title('power spectrum of .eeg file - on log scale')

% save figure to file
if saveFigures
    filename = sprintf('%s/timefrequency_wavelets', folderOutput);
    ExportFigure(filename, dpi);
end
