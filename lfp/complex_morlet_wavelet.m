function cmw = complex_morlet_wavelet(t,f,nCycles)
% assert that t and f are column vectors, so that we can generate all
% wavelets in one go (i.e. vectorized)
t = reshape(t,[],1);
f = reshape(f,[],1);

% create tapper
s = nCycles ./ (2*pi*f);
tapper = exp((-t.^2) * (2.*s.^2).^(-1)'); 

% create amplitutde
A = 1./(s*sqrt(pi)).^0.5; 
A = repmat(A, 1, length(t))'; % replicate amplitute for all timepoints for easy element-wise multiplication below

% create oscillation
oscillation = exp(2*pi*t*f'* 1i);

% compbine all three
cmw = A .* tapper .* oscillation;

end