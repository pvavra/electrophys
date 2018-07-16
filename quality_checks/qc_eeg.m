function qc_eeg(folderData, filenameDataCommon,nTetrode, filenameOutputBase)

if nargin < 4
    filenameOutputBase = sprintf('%s_qc_eeg', filenameDataCommon);
end

% for each tetrode, there are expected to be 4 channels, so nTetrode*4
% channels in total

% load input data (i.e. timestamps of shock/tone
inputs = LoadInputs(sprintf('%s/%s',folderData, filenameDataCommon));
[shock_timestamps, shock_durations] = GetEventsOfInterest(inputs, 'shock');
[tone_timestamps, tone_durations] = GetEventsOfInterest(inputs, 'tone');
% for hard-coding of 5 shocks below (easier to read), check first that this
% assumption is correct:
assert(length(shock_timestamps) == 5, 'expecting to see 5 shocks, instead found %i', length(shock_timestamps));


colorShock = 'r';

% we'll be removing a period around the shock (starting at shock-onset,
% 10s in total; i.e. 9s after shock-offset); here we check whether any
% EEG signal reaches the boundaries outside this period - it should not
filterOnset = 0; % in seconds; relative to shock_onset
filterDuration = 10; % i.e. 10s in total
colorFilter = [.5 .7 .5]; % RGB value, scaled to [0 1] 

for iChannel = 1:(nTetrode*4)
    switch iChannel
        case 1
            eeg_filename = sprintf('%s/%s.egf', folderData, filenameDataCommon);
        otherwise
            eeg_filename = sprintf('%s/%s.egf%i', folderData, filenameDataCommon,iChannel);
    end
    % load eeg data
    [header, eeg] = read_eeg_file(eeg_filename);
    
    
    
    % start plotting
    %----------------------------------------------------------------------
    figure(iChannel)
    clf
    set(gcf, 'Name',sprintf('Quality Assurance of `%s` - EEG channel %i', filenameDataCommon, iChannel))
    
    nRows = 6; nCols = 2;
    
    % full timeseries
    %----------------------------------------------------------------------
    subplot(nRows,nCols, 1)
    hold off
    % plot full timeseries
    PlotEEGTimeseries(...
        eeg, ...
        0, ... % tmin
        (length(eeg)-1) / header.sample_rate, ... %max
        header.sample_rate,...
        'k.-'...
        );
    hold on
    % add overlay for shocks
    yStart = -2^(8*header.bytes_per_sample)/2; yEnd = -yStart;
    ylim([yStart yEnd])
    for iShock = 1:5
        xLeftEdge = shock_timestamps(iShock); xRightEdge = shock_timestamps(iShock) + shock_durations(iShock);
        patch([xLeftEdge xRightEdge xRightEdge xLeftEdge], [yStart yStart yEnd yEnd], colorShock, 'FaceAlpha',.5,'EdgeColor',colorShock);
        
    end
    title('Full timeseries')
    
    % create zooms around shocks
    %----------------------------------------------------------------------
    preShock = 1; % in seconds - how much to include before shock-onset
    postShock = 10; % in seconds - how much to include after the shock-offset
    for iShock = 1:5
        % define range around shock
        range = [shock_timestamps(iShock)-preShock shock_timestamps(iShock)+shock_durations(iShock)+postShock];
        
        % create plot
        subplot(nRows, nCols, iShock*2) % put in right column
        hold off
        % add highlight for shock period
        yStart = -2^(8*header.bytes_per_sample)/2;
        yEnd = 2^(8*header.bytes_per_sample)/2;
        xLeftEdge = shock_timestamps(iShock); xRightEdge = shock_timestamps(iShock) + shock_durations(iShock);
        patch([xLeftEdge xRightEdge xRightEdge xLeftEdge], [yStart yStart yEnd yEnd], colorShock, 'FaceAlpha',.5,'EdgeColor',colorShock);
        hold on
        % add highlight for filtered duration        
        xLeftEdge = shock_timestamps(iShock)+filterOnset;
        xRightEdge = shock_timestamps(iShock)+filterOnset+filterDuration;
        patch([xLeftEdge xRightEdge xRightEdge xLeftEdge], [yStart yStart yEnd yEnd], colorFilter, 'FaceAlpha',.5,'EdgeColor',colorFilter);
        
        % add timeseries on top of it
        PlotEEGTimeseries(...
            eeg, ...
            range(1), ... % tmin
            range(2), ... %max
            header.sample_rate,...
            'k.-'...
            );
        title(sprintf('zoom around shock %i',iShock))
        grid on
        ylim([yStart yEnd]);
    end
    
    
    % Plot Histogram over all y-values of EEG data
    %----------------------------------------------------------------------
    subplot(nRows,nCols, 3)
    xRightEdge = 2^(8*header.bytes_per_sample)/2;
    xLeftEdge = -xRightEdge;
    nBins = 100;
    edgeStepSize = round(2^(8*header.bytes_per_sample)/nBins );
    h=histogram(eeg,xLeftEdge:edgeStepSize:xRightEdge);
    % add overlays for outside of the valid range
    yl = ylim; ylim([yl(1) max(h.Values)*1.1])
    yStart = yl(1); yEnd = max(h.Values)*1.1;
    patchWidth = 10;
    patch([xLeftEdge-patchWidth xLeftEdge xLeftEdge xLeftEdge-patchWidth], [yStart yStart yEnd yEnd], colorShock, 'FaceAlpha',.5,'EdgeColor',colorShock);
    patch([xRightEdge+patchWidth xRightEdge xRightEdge xRightEdge+patchWidth], [yStart yStart yEnd yEnd], colorShock, 'FaceAlpha',.5,'EdgeColor',colorShock);
    xlim([xLeftEdge-patchWidth xRightEdge+patchWidth])
    title('Distribution of EEG-values')
    
    % Plot Histogram over all y-values, exlcuding those during 'around
    % shock' period
    %----------------------------------------------------------------------
    % figure out which samples are inside the 'to remove' time-windows
    % convert into samples
    toRemoveOnsets = floor((shock_timestamps + filterOnset) * header.sample_rate); % round downwards, to include more samples, if in doubt
    toRemoveOffset = ceil((shock_timestamps + filterDuration) * header.sample_rate); % same as above, but upwards
    
    indicesToRemove = [];
    for i = 1:length(toRemoveOnsets)
        indicesToRemove = [indicesToRemove toRemoveOnsets(i):toRemoveOffset(i)];
    end
    validIndices = setdiff(1:length(eeg), indicesToRemove);
    
    subplot(nRows,nCols, 5)
    hold off
    % define the edges of the histogram
    xRightEdge = 2^(8*header.bytes_per_sample)/2;
    xLeftEdge = -xRightEdge;
    nBins = 100;
    edgeStepSize = round(2^(8*header.bytes_per_sample)/nBins );
    
    h=histogram(eeg(validIndices),xLeftEdge:edgeStepSize:xRightEdge);
    hold on
    % add overlays for outside of the valid range
    yl = ylim; ylim([yl(1) max(h.Values)*1.1])
    yStart = yl(1); yEnd = max(h.Values)*1.1;
    patchWidth = 10;
    patch([xLeftEdge-patchWidth xLeftEdge xLeftEdge xLeftEdge-patchWidth], [yStart yStart yEnd yEnd], colorShock, 'FaceAlpha',.5,'EdgeColor',colorShock);
    patch([xRightEdge+patchWidth xRightEdge xRightEdge xRightEdge+patchWidth], [yStart yStart yEnd yEnd], colorShock, 'FaceAlpha',.5,'EdgeColor',colorShock);
    xlim([xLeftEdge-patchWidth xRightEdge+patchWidth])
    title('Distribution of EEG-values - filtered')
    
    % Plot timeseries around tone - to check for theta
    %----------------------------------------------------------------------
    rangeStart = tone_timestamps(1) - 5; % start 5s prior to tone-onset
    rangeEnd = tone_timestamps(1); % stop at tone onset
    
    
    
    subplot(nRows, nCols, 7)
    hold off
    % plot full timeseries
    PlotEEGTimeseries(...
        eeg, ...
        rangeStart, ... % tmin
        rangeEnd, ... %max
        header.sample_rate,...
        'k.-'...
        );
    hold on
    % add overlay for shocks
    yStart = -2^(8*header.bytes_per_sample)/2; yEnd = -yStart;
    ylim([yStart yEnd])
    title('Zoom of timeseries before first tone')
    
    % Plot power spectrum - to check for theta
    %----------------------------------------------------------------------
    L = length(eeg);
    frequencies = header.sample_rate * (0:(L/2))/L; % infer which frequencies are possible
    spectrum = PowerSpectrum(eeg);
    
    subplot(nRows, nCols, 9)
    hold off
    freq_upperLimit = 100; % plot only frequencies lower than this
    indices_subset = frequencies < freq_upperLimit;
    plot(frequencies(indices_subset),spectrum(indices_subset )/max(spectrum(indices_subset)))
    xlabel('frequency [Hz]')
    ylabel('normalized power')
    % title(sprintf('Power spectrum - frequencies < %g Hz', freq_upperLimit));
    xlim([0 max(frequencies(indices_subset))])
    
    subplot(nRows, nCols, 11)
    hold off
    freq_upperLimit = 20; % plot only frequencies lower than this
    indices_subset = frequencies < freq_upperLimit;
    plot(frequencies(indices_subset ),spectrum(indices_subset )/max(spectrum(indices_subset)))
    xlabel('frequency [Hz]')
    ylabel('normalized power')
    % title(sprintf('Power spectrum - frequencies < %g Hz', freq_upperLimit));
    xlim([0 max(frequencies(indices_subset))])
    
    
    % Plot time-frequency spectrum
    %----------------------------------------------------------------------
    nCyclesWithinWavelet = 20;
    freq_of_interest = 1:2:50; 
    
    [tf_power, ~] = TF_wavelets(eeg, freq_of_interest, nCyclesWithinWavelet, header.sample_rate);
    
    
    subplot(nRows, nCols, 12)
    hold off
    imagesc(tf_power')
    axis xy
    xlabel('time [s]')
    timeTicks = 0:100:length(eeg)/header.sample_rate; % i.e. 0:100:tmax
    set(gca, 'XTick',timeTicks*header.sample_rate)
    set(gca, 'XTickLabel', num2str(timeTicks'))
    ylabel(sprintf('Frequency [Hz]'))
    freqTicks = 1:5:length(freq_of_interest);
    set(gca, 'YTick',freqTicks)
    set(gca, 'YTickLabel',num2str(freq_of_interest(freqTicks)'))
    % title(sprintf('Time-Frequency spectrum (based on wavelets w/ %g cylces)', nCyclesWithinWavelet))
    
    % add overlay for shocks
    currentSamplingRate = header.sample_rate;
    ylim([1 length(freq_of_interest)])
    for iShock = 1:5
        xLeftEdge = shock_timestamps(iShock); xRightEdge = shock_timestamps(iShock) + shock_durations(iShock);
        xLeftEdge = xLeftEdge * currentSamplingRate; xRightEdge = xRightEdge * currentSamplingRate;
        patch([xLeftEdge xRightEdge xRightEdge xLeftEdge], [yStart yStart yEnd yEnd], colorShock, 'FaceAlpha',.5,'EdgeColor',colorShock);
        
    end
    
    %% save figure to file
    filenameOutput = sprintf('%s_channel%i.jpg',filenameOutputBase, iChannel);
    set(gcf, 'Units', 'pixels', 'Position', [0 0 1920 1080]);
    saveas(gcf, filenameOutput);
    
    
end


end


