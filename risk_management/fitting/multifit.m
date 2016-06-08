function [vEnd_f, yEnd_f, err] =multifit (allg2_delays,allg2_functions,xVector,fun,v)

%   [fit_par_Maj_6Km,fit_curves_Maj_6Km,fit_err_Maj_6Km] =multifit(allg2_delay,allg2_Maj_6Km,@expkww,[0,1,500,1]);

[~,cv]=size(v);
[r,c]=size(allg2_functions);
vEnd_f=zeros(c,cv);
yEnd_f=zeros(r,cv);
err=zeros(c,1);

%xVector=c:-1:1;
last=max(allg2_delays(:));

for i=1:c
[fit,values,er] = fit1(1,allg2_delays(:,i),allg2_functions(:,i),fun,v);
vEnd_f(i,:)=fit;
yEnd_f(:,i)=values;
err(i,1)=er;
end

figure(15)
subplot(3,2,1)
plot(xVector,vEnd_f(:,1),'-ob');
%plot(IntVector,vEnd_f(:,3),'-ob');
%axis([0 10 100 600]);
h1=xlabel ('Temperature (K)','FontSize',12,'FontName','arial');
h2=ylabel ('scale factor','FontSize',12,'FontName','arial');
set([h1 h2], 'interpreter', 'tex')
% title('relaxation time');

subplot(3,2,3)
plot(xVector,vEnd_f(:,2),'-ob');
%plot(IntVector,vEnd_f(:,3),'-ob');
%axis([0 10 100 600]);
h1=xlabel ('Temperature (K)','FontSize',12,'FontName','arial');
h2=ylabel ('relaxation time \tau (sec)','FontSize',12,'FontName','arial');
set([h1 h2], 'interpreter', 'tex')
% title('relaxation time');

subplot(3,2,5)
plot(xVector,vEnd_f(:,3),'-or');
%plot(IntVector,vEnd_f(:,4),'-or');
%axis([0 10 1 3.1]);
h1=xlabel ('Temperature (K)','FontSize',12,'FontName','arial');
h2=ylabel ('critical exponent (\beta)','FontSize',12,'FontName','arial');
set([h1 h2], 'interpreter', 'tex')
% title('beta exponent');

subplot(3,2,[2,4,6])
for i= 1:c
semilogx(allg2_delays(:,i),allg2_functions(:,i),'-ob');
axis([0 last+1000 0.001 1.1]);
hold on
plot(allg2_delays(:,i),yEnd_f(:,i),'-r');
h1=xlabel ('time [sec]','FontSize',12,'FontName','arial');
h2=ylabel ('g2 function','FontSize',12,'FontName','arial');
set([h1 h2], 'interpreter', 'tex')
end