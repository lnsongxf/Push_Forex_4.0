function cy = fourierApp( v1, n )

ey = v1;
eY = fft(ey); % Fourier transform of noisy signal enter
r = sqrt(real(eY).^2+imag(eY).^2);
nMax = iterativeMax(r,3);
fY = eY.*(r >= nMax);
ifY = ifft(fY ); % inverse Fourier transform of ¯xed data enter
cy = real(ifY ); % remove imaginary parts enter
plot(v1)
hold on
plot(cy,'red')

end