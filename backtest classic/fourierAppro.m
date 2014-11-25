function y = fourierAppro(vettore,ind)
hold off;
fa = fft(vettore);
N = length(vettore);

fa_N = fa;
fa_N(ind+1:N-ind+1) = 0;
y = real(ifft(fa_N));
plot(y,'r');
hold on;
plot(vettore,'b');

end