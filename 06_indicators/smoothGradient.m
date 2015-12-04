function [smoothSeries,gradientSeries]=smoothGradient(series,smoothCoeff)

a = (1/smoothCoeff)*ones(1,smoothCoeff);
smoothSeries = filter(a,1,series);
gradientSeries=gradient(smoothSeries);

end