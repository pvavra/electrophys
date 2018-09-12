% This script compares the position data, as stored by AXONA and the
% TRUSCAN system respectively.

%% Setup & Initialization
%==========================================================================
% load required modules
addpath('axona_io');
addpath('truscan_io');
addpath('plotting');

% define data files
filenameAXONA   = '/data/fred_old/Dataset Mouse 304/Converted no Ref/304D1TFC.pos';
filenameTRUSCAN = '/data/fred_old/Dataset Mouse 304/304TFCD1xdata.xlsx'; 

%% Load Position Data
%==========================================================================
% Load AXONA data
%--------------------------------------------------------------------------
[positions_axona, header_axona] = read_pos_file(filenameAXONA, true);

% Load TRUSCAN data
%--------------------------------------------------------------------------
[positions_truescan, header_truescan] = read_truscan_positions(filenameTRUSCAN);


%% Plot each position data separately
%==========================================================================
% Plot AXONA data
%--------------------------------------------------------------------------
% plot simple scatter plot of positions 
PlotPositionScatter(positions_axona.x1,positions_axona.y1 );

% Plot TRUSCAN data
%--------------------------------------------------------------------------
PlotPositionScatter(positions_truescan.x, positions_truescan.y);


%% Estimate correlations
%==========================================================================
% Because of the different sampling frequencies, we cannot simly calculate
% a correlation. First, we need interpolate the data to the same
% timepoints. Specifically, we interpolate the axona data onto the same
% time-axis as the truscan samples (interpolating the more highly sampled
% data is more accurate in general):
positions_interpolated = struct();

% Note: we are not using all datapoints of the axona system. Instead, we
% drop all zeros - it seems that the axona system reports a lot of 0 when
% it is unsure about the position (or there is a reflection in the corner
% of the arena..)
subset = (positions_axona.x1 ~= 0) & (positions_axona.y1 ~= 0);
positions_interpolated.x = interp1(time_axona(subset), positions_axona.x1(subset), positions_truescan.Time);
positions_interpolated.y = interp1(time_axona(subset), positions_axona.y1(subset), positions_truescan.Time);
% An alternative would be to use all datapoints:
% positions_interpolated.x = interp1(time_axona, positions_axona.x1, positions_truescan.Time);
% positions_interpolated.y = interp1(time_axona, positions_axona.y1, positions_truescan.Time);

% now we can calculate & plot the correlations
X = {positions_truescan.x, positions_truescan.y};
X_labels = {'x [truscan]', 'y [truscan]'};
Y = {positions_interpolated.x, positions_interpolated.y};
Y_labels = {'x [axona]', 'y [axona]'};
figure(4)
for iX = 1:length(X)
    for iY = 1:length(Y)
        subplot(length(X), length(Y), iX + (iY-1)*length(X))
        PlotCorrelation(X{iX}, Y{iY},X_labels{iX}, Y_labels{iY});
    end
end

% NOTE 1: we can see that the x/x and y/y plots have larger correlations
% than the x/y and y/x plots. This implies that both systems seem to label
% the same physical axes as 'x' and 'y' respectively. 
% 
% NOTE 2: Because the correlation for x/x is negative (-0.75), this
% suggests that the x-values are flipped in sign (i.e. x_axona = -
% x_truscan)
% 
% Thus, let's flip the sign of the x-positions in the truscan dataset. But
% let's make sure to shift the positions back into the default range,
% namely 0 - 32
positions_truescan.x = header_truescan.nx - positions_truescan.x;



%% Plot timeseries of TRUSCAN and AXONA
%==========================================================================
% For this comparison, we need to account for the different sampling
% frequencies of the two systems. Axona samples at 50Hz, while Truscan at
% up to 10Hz. 

% create time-axis for axona
time_axona = (0:(length(positions_axona.x1) -1)) / 50; 

% Compare timeseries 
figure(3)
clf
subplot(211)
yyaxis left % put this data on left y-axis
plot(time_axona(positions_axona.x1 ~= 0), positions_axona.x1(positions_axona.x1 ~= 0), '.-', ...
    'DisplayName', 'AXONA (zeros removed)')
hold on
yyaxis right % put this on the right y-axis
plot(positions_truescan.Time, positions_truescan.x, '.-','DisplayName', 'TRUSCAN')
legend
title('x position')


subplot(212)
yyaxis left % put this data on left y-axis
plot(time_axona(positions_axona.y1 ~= 0), positions_axona.y1(positions_axona.y1 ~= 0), '.-', ...
    'DisplayName', 'AXONA (zeros removed)')
hold on
yyaxis right % put this on the right y-axis
plot(positions_truescan.Time, positions_truescan.y, '.-','DisplayName', 'TRUSCAN')
legend
title('y position')
