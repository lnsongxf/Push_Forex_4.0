function [smoothSeries,diffSeries]=smoothDiff(series,smoothCoeff)

smoothSeries = smooth(series,smoothCoeff,'rloess');
diffSeries=diff(smoothSeries);

end