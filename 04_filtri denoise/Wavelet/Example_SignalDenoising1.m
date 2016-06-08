%s1 = double(imread('peppers.jpg'));	% load image as a double
%s = s1(:,4,3);                      % convert 3-D image to a 1-D signal
%subplot (3,1,1), plot(s)            % plot the original signal
%title('Original Signal')
%axis([0 512 -100 300])
%x = s + 20*randn(size(s));          % add Gaussian noise to the original signal
start = tic; 
Mean_N = [];
Dev_N = [];
POWER_N = [];
POWER_X = [];
POWER_Y = [];
z = 64; %64 112 512
vettore = csvread('EURUSD1ee.csv');
vettore2 = vettore(:,4);
for j = 1:15640       %15200


vettore3 = vettore2(j:z,:);    %14256
z = z + 1;
x = vettore3;


T = 10;                             % choose a threshold of 20
y = double_S1D(x,T);  % denoise the noisy image using Double-Density Dual-Tree DWT



last_x = vettore3(1:64,:);
last_y = y(1:64,:);

last_noise = last_x - last_y;
[mu,s,muci,sci] = normfit(last_noise);

POWER_X(j) = mean(last_x.^2)
POWER_Y(j) = mean(last_y.^2)
POWER_N(j) = mean(last_noise)
Mean_N(j) = mu
Dev_N(j) = s



%subplot (2,1,1), plot(x)            % plot the noisy signal
%title('Noisy Signal')
%subplot (2,1,2), plot(y)            % plot the denoised signal
%title('Denoised Signal')

end;

subplot(5,1,1),plot(POWER_X)
title('POWER_X')
subplot(5,1,2),plot(POWER_Y)
title('POWER_Y')
subplot(5,1,3),plot(POWER_N)
title('POWER_N')
subplot(5,1,4),plot(Mean_N)
title('Mean_N')
subplot(5,1,5),plot(Dev_N)
title('Dev_N')
elapsed = toc(start);




%Fs = 32e2;

%X = fft(last_x);
%X=X(1:length(X)/2+1); %one-sided DFT
%P = (abs(X)/length(last_x)).^2;     % Compute the mean-square power
%P(2:end-1)=2*P(2:end-1); % Factor of two for one-sided estimate
% at all frequencies except zero and the Nyquist
%Hmss1=dspdata.msspectrum(P,'Fs',Fs,'spectrumtype','onesided'); 
%subplot (4,1,3), plot(Hmss1);          % Plot the mean-square spectrum.
%title('Noisy Power')


%Y = fft(last_y);
%Y=Y(1:length(Y)/2+1); %one-sided DFT
%P2 = (abs(Y)/length(last_y)).^2;     % Compute the mean-square power
%P2(2:end-1)=2*P2(2:end-1); % Factor of two for one-sided estimate
% at all frequencies except zero and the Nyquist
%Hmss2=dspdata.msspectrum(P2,'Fs',Fs,'spectrumtype','onesided'); 
%subplot (4,1,4),plot(Hmss2);          % Plot the mean-square spectrum.
%title('Denoised Power')


