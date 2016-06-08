function [fx,tx,FT]=fourierComponent1D(inputVector)

% Fs = 1000;                    % Sampling frequency
% T = 1/Fs;                     % Sample time
% L = 1000;                     % Length of signal
% t = (0:L-1)*T;                % Time vector
% % Sum of a 50 Hz sinusoid and a 120 Hz sinusoid
% x = 0.7*sin(2*pi*50*t)



Fs=1;           % 1 == 1 passo 1 sec(o micron) 
L=1000000;         % sampling of the input (free values)
y=inputVector;

% figure
% plot(y)

% Furier Components
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y,NFFT)/L;
fx = (Fs/2*linspace(0,1,NFFT/2+1))';
FT=2*abs(Y(1:NFFT/2+1));

% time domain

tx=(1./fx);

% Plot single-sided amplitude spectrum.
figure
subplot (1,2,1)
plot(fx,FT) 
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|FT(x)|')

subplot (1,2,2)
plot(tx,FT) 
title('Single-Sided Periodicity Spectrum of y(t)')
xlabel('Periodicity (micron)')
ylabel('|FT(x)|')



