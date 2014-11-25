function [params]=showFitSDF(dataCol,hx,h)

params = stblfit(dataCol);
area=trapz(hx,h);
h_PDF=h/area;
p = stblpdf(hx,params(1),params(2),params(3),params(4));

subplot(1,2,1)
plot(hx,h_PDF,'ob')
hold on
plot(hx,p,'-r');

subplot(1,2,2)
semilogy(hx,h_PDF,'ob')
hold on
semilogy(hx,p,'-r');

end