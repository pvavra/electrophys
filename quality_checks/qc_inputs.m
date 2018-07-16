function qc_inputs(folderData, filenameDataCommon, filenameOutputBase)

% set default filename for output
if nargin <= 2
    filenameOutputBase = sprintf('%s_qc_input',filenameDataCommon);
end

%% load input data (i.e. timestamps of shock/tone)
[inputs] = LoadInputs(sprintf('%s/%s',folderData, filenameDataCommon));
[shock_timestamps, shock_durations] = GetEventsOfInterest(inputs, 'shock');
[tone_timestamps, tone_durations] = GetEventsOfInterest(inputs, 'tone');
[tracking_timestamps, tracking_durations] = GetEventsOfInterest(inputs, 'tracking');

colorShock = 'r';
colorTone = 'b';
colorTracking = 'g';


tmin = 0;
tmax = max(inputs.timestamps_onset)+max(inputs.durations); 

%% Start plotting
figure(1);
clf
set(gcf, 'Name',sprintf('Quality Assurance of `%s` - inputs (i.e. timestamps)', filenameDataCommon))
nRows = 2; nCols = 2;


%% plot all timestamps
subplot(nRows, nCols, 1);
hold off
% add patches for shock
for iPatch=1:length(shock_timestamps)
   pShock = AddPatch(shock_timestamps(iPatch), shock_durations(iPatch), 0, 1, colorShock, 'DisplayName','test');
end
% add patches for tone
for iPatch=1:length(tone_timestamps)
   pTone = AddPatch(tone_timestamps(iPatch), tone_durations(iPatch), 0, 1, colorTone);
end
% add patches for tracking
for iPatch=1:length(tracking_timestamps)
   pTracking = AddPatch(tracking_timestamps(iPatch), tracking_durations(iPatch), 1, 2, colorTracking);
end
xlim([tmin tmax])
ylim([0 2])
xlabel('time [s]')
title('full set of input timestamps')
legend([pShock pTone pTracking], 'shock', 'tone', 'tracking')

%% plot zoom around first couple of tracking timestamps
subplot(nRows, nCols, 2)
hold off
tmax = 10+tracking_timestamps(10); % inspect the first couple of tracking timestamps -- should have three quickly one after another
% add patches for tracking
for iPatch=1:length(tracking_timestamps)
   AddPatch(tracking_timestamps(iPatch), tracking_durations(iPatch), 0, 1, colorTracking, 'DisplayName','test');
end
% add patches for tone
for iPatch=1:length(tone_timestamps)
   AddPatch(tone_timestamps(iPatch), tone_durations(iPatch), 0, 1, colorTone); 
end
% add patches for tracking
for iPatch=1:length(tracking_timestamps)
   AddPatch(tracking_timestamps(iPatch), tracking_durations(iPatch), 1, 2, colorTracking); 
end
xlim([tmin tmax])
ylim([0 2])
xlabel('time [s]')
title('zoom around first couple of tracking timestamps')

%% plot inter-tracking-timestamp-intervals
subplot(nRows, nCols, 3)
plot(diff(tracking_timestamps([1 4:end])),'.-') % skipping first three timestamps
title('inter-timestamp-intervals: Tracking (excl. 2nd & 3rd timestamp)')


%% add inter-trial and within-trial timing text to figure
txtStats = '';
for iTrial = 1:length(tone_timestamps)
    txtStats = sprintf('%sTrial %i: Tone duration = %.4f; Trace duration = %.4f; Shock duration = %.4f\n', ...
        txtStats, ...
        iTrial,...
        tone_durations(iTrial), ...
        shock_timestamps(iTrial) - (tone_timestamps(iTrial) + tone_durations(iTrial)), ...
        shock_durations(iTrial)...
        );
end
txtStats = sprintf('%s\n',txtStats); % add empty line
% add intertrail info:
ITIs = diff(tone_timestamps);
for iITI = 1:length(ITIs)
   txtStats = sprintf('%sInterTrialInterval %i : %.4f s\n', txtStats,iITI, ITIs(iITI));
end


annotation('textbox',...%  'Style','text',...
    'Position', [.5 .1 .4 .4],...
    'Units', 'normalized',...
    'FontSize',12,...
    'String', txtStats);

%% save resulting figure
filenameOutput = sprintf('%s.jpg',filenameOutputBase);
set(figure(1), 'Units', 'pixels', 'Position', [0 0 1920 1080]);
saveas(figure(1), filenameOutput)

end

function p = AddPatch(onset, duration, yStart, yEnd, colorPatch, varargin)
    p = patch(...
        [onset onset+duration onset+duration onset],...
        [yStart yStart yEnd yEnd], ...
        colorPatch, 'EdgeColor', colorPatch, varargin{:} );
end
