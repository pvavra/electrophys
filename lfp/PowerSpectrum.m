function spectrum = PowerSpectrum(signal)

% cf. `help fft`

% calculate length of signal
L = length(signal);

% calculate fourier transfrom
fourier = fft(signal,L); % gives the two-sided spectrum

% calculate two-sided spectrum, scaled based on number of samples
spectrum_twosided = abs(fourier/L);

% reflect negative frequencies into positive 
spectrum = spectrum_twosided(1:(L/2+1));
spectrum(2:end-1) = 2 * spectrum(2:end-1);

% scale based on number of samples and calculate power
spectrum = abs(spectrum).^2;

end