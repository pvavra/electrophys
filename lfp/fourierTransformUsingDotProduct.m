function [fourier, power, phase] = fourierTransformUsingDotProduct(data)

fourier = zeros(size(data)); % complex transform
N = length(data);

% define time as starting w/ zero
time = (0:(N-1))/N;

for iFrequency = 1:N
    sine_wave = exp(-1i*2*pi*(iFrequency-1).*time); % shift frequencies by '-1' to include DC component
    fourier(iFrequency) = sum(sine_wave.*data);
end

power = 2*abs(fourier(1:(N/2+1))); % pick positive frequencies and multiply by 2 to keep power present also in negative ones
power = power / N; % scale down power, by accounting for nr of data-points
phase = angle(fourier);

end