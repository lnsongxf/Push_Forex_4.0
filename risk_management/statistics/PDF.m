function [xPDF,hPDF,hBin]=PDF(values,valueMin,valueMax,n)

% valueMax is the max value for the binning
% valueMin is the min value for the binning
% n number of points

xPDF=valueMin:(valueMax-valueMin)/(n-1):valueMax;
hBin=hist(values,xPDF);

area=trapz(xPDF,hBin);
hPDF=hBin./area;


end