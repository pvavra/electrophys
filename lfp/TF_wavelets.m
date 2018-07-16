function [tf_power, tf_phase] = TF_wavelets(Signal, fois, nCycles, Fs)


% infer good wavelets kernel size
%--------------------------------------------------------------------------
% accept wavelet kernel size, if for largest frequency, the tapper is down
% to a value of `tapper_tolerance`
tapper_tolerance = 1/1000; % should be close to zero
tmax = round(sqrt(-2 * (nCycles/(2*pi*min(fois)))^2 * log(tapper_tolerance))); % this is `tolerance = exp((-tmax.^2) * (2.*s.^2).^(-1))` solved for tmax, with s = n / (2*pi*f)
t = -tmax:1/Fs:tmax; % define time-axis for kernel

% get complex Morlet wavelets
%--------------------------------------------------------------------------
cmw = complex_morlet_wavelet(t,fois,nCycles); % has dimension nSamples x nWavelets

% calculate Fourier of wavelets and of signal
%--------------------------------------------------------------------------
lengthKernel = size(cmw,1);
nFourierSamples = length(Signal) + lengthKernel - 1;
FFT_Signal = fft(Signal,nFourierSamples); FFT_Signal = reshape(FFT_Signal, [],1);
FFT_cmw = fft(cmw,nFourierSamples);

prod = FFT_Signal .* FFT_cmw;
complex_TF = ifft(prod); 
% remove zero-padding
complex_TF = complex_TF((1+(lengthKernel-1)/2):(end - (lengthKernel-1)/2),:);

tf_power = complex_TF .* conj(complex_TF); 
tf_phase = angle(complex_TF);


% figure(1)
% subplot(311)
% title('real component of wavelet')
% imagesc(t,fois,real(cmw)')
% axis xy
% colormap('gray')
% 
% subplot(312)
% title('imaginary component of wavelet')
% imagesc(t,fois,imag(cmw)')
% axis xy
% colormap('gray')
% 
% subplot(313)
% title('abs of wavelet')
% imagesc(t,fois,abs(cmw)')
% axis xy
% colormap('gray')

end

