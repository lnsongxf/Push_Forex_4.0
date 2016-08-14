function [xPDF,hPDF,hBin]=PDF(values,n)

% valueMax is the max value for calculating the binning step
% valueMin is the min value for calculating the binning step
% n number of points

valueMax = max(values(:));
valueMin = min(values(:));
xPDF=valueMin:(valueMax-valueMin)/(n-1):valueMax;
hBin=hist(values,xPDF);

area=trapz(xPDF,hBin);
hPDF=hBin./area;


end