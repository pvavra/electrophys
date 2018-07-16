%% define settings
Fs = 1000;            % Sampling frequency in Hz
T = 1/Fs;             % Sampling period in seconds (i.e. duration between two consecutive samples)
L = 6000;             % Length of signal, i.e. nr of samples
tmax = T*(L-1);       % Total sampling duration in seconds (the 'minus one' is because the first sample starts at t=0)

% infer time-axis:
t = (0:L-1)*T;        % Time vector
% t = 0:T:tmax;       % alternative definition of Time vector

% infer which fourier-frequencies will be available:
f = Fs*(0:(L/2))/L;

%% signal definition
frequencies = [50 120]; % in Hz
amplitudes  = [0.7 1 ];
phases      = [0 pi];     % in rad
boundaries  =   [... % make the signal switch from one freq to other
    1 floor(L/2);... % boundaries for first freq-signal
    ceil(L/2) L... % and boundaries for second signal
    ];

S = zeros(size(t));  % start with empty signal
for i = 1:length(frequencies) % add up all components
    % define where the signal will be
    windowSignal = zeros(size(t)); windowSignal(boundaries(i,1):boundaries(i,2)) = 1;
    S =  S + amplitudes(i) * sin(2*pi*frequencies(i)*t + phases(i)) .* windowSignal;
end

% add some noise
X = S + 2*randn(size(t));

%% compute power spectrum - using FFT
Y = fft(X);
P2 = abs(Y/L);
P_noisy = P2(1:L/2+1);
P_noisy(2:end-1) = 2*P_noisy(2:end-1);

Y = fft(S);
P2 = abs(Y/L);
P_pure = P2(1:L/2+1);
P_pure(2:end-1) = 2*P_pure(2:end-1);

%% compute power spectrum - using dot-product w/ sine waves
[Y, P_dp_pure, phase_dp_pure] = fourierTransformUsingDotProduct(S);
[Y, P_dp_noisy, phase_dp_noisy] = fourierTransformUsingDotProduct(X);

%% copmute time-frequency decomposition using Morlet wavelets
frequencies_of_interest =1:2:200;
n_cycles_per_waveform = 7;
tic
[tf_power , tf_phase] = TF_wavelets(S, frequencies_of_interest, n_cycles_per_waveform, Fs);
toc
tic
[tf_power_conv , tf_phase_conv] = TF_wavelets_conv(S, frequencies_of_interest, n_cycles_per_waveform, Fs);
toc

%% Plot signal
figure(1)
nrows = 8; ncols = 1;
currentPlot = 1;

subplot(nrows, ncols, currentPlot); currentPlot = currentPlot + 1;
% define which samples to look at:
hold off
plot(t,S,'DisplayName','Signal without noise')
title('The whole timeseries')
xlabel('t (seconds)')
ylabel('X(t)')
legend


subplot(nrows, ncols, currentPlot); currentPlot = currentPlot + 1;

% define which samples to look at:
indZoom = 1:100; % look at the first 50 samples only
hold off
plot(1000*t(indZoom),X(indZoom),'DisplayName','Signal Corrupted with Zero-Mean Gaussian Noise')
hold on
plot(1000*t(indZoom),S(indZoom),'DisplayName','Signal - pure')
title('Small section of the signal')
xlabel('t (milliseconds)')
ylabel('X(t)')
legend


%% plot power spectrum - as calculated using FFT
subplot(nrows, ncols, currentPlot); currentPlot = currentPlot + 1;
hold off
plot(f,P_noisy,'b', 'DisplayName','Single-Sided Amplitude Spectrum of X(t)')
hold on
plot(f,P_pure,'r','DisplayName','Single-Sided Amplitude Spectrum of S(t)')

title('Fourier Spectrum - based on fft()')
xlabel('f (Hz)')
ylabel('|Amplitude|')
legend

%% plot power of the original signal (w/out noise)
subplot(nrows, ncols, currentPlot); currentPlot = currentPlot + 1;
hold off
plot(f,P_dp_noisy,'b', 'DisplayName','Single-Sided Amplitude Spectrum of X(t)')
hold on
plot(f,P_dp_pure,'r','DisplayName','Single-Sided Amplitude Spectrum of S(t)')

title('Fourier Spectrum - based on dot-product()')
xlabel('f (Hz)')
ylabel('|Amplitude|')
legend


%% plot power spectrum - as calculated using `PowerSpectrum`
subplot(nrows, ncols, currentPlot); currentPlot = currentPlot + 1;
hold off
plot(f,PowerSpectrum(X),'b', 'DisplayName','Power Spectrum of X(t)')
hold on
plot(f,PowerSpectrum(S),'r','DisplayName','Power Spectrum of S(t)')

title('Power Spectrum - based on PowerSpectrum()')
xlabel('f (Hz)')
ylabel('Power')
legend



%% Plot phase spectrum (w/ and w/out noise)
subplot(nrows, ncols, currentPlot); currentPlot = currentPlot + 1;
hold off
plot(f,phase_dp_pure(1:(L/2+1)),'DisplayName', 'Phase of signal (no noise) first half')
hold on
plot(f,phase_dp_noisy(1:(L/2+1)),'DisplayName', 'Phase of signal (w/ noise) first half')
title('Phase Spectrum')
xlabel('f (Hz)')
ylabel('Phase')
legend

%% Time-Frequency plot using Morlet wavelet
subplot(nrows, ncols, currentPlot); currentPlot = currentPlot + 1;
hold off
title('Time-Frequency plot using Morlet wavelets')
imagesc(t,frequencies_of_interest,tf_power')
axis xy
xlabel('t (s)')
ylabel('frequency')

%% Time-Frequency plot using Morlet wavelet - based on convolution
subplot(nrows, ncols, currentPlot); currentPlot = currentPlot + 1;
hold off
title('Time-Frequency plot using Morlet wavelets')
imagesc(t,frequencies_of_interest,tf_power_conv')
axis xy
xlabel('t (s)')
ylabel('frequency')