function [ numAvg ] = AvgTrueRange( matrix, numOfCandles )
%average of true ranges
%Given an set of historycal points, return the average of the true ranges.

distHL = abs(matrix(end-numOfCandles+1:end,2) - matrix(end-numOfCandles+1:end,3));
distHC = abs(matrix(end-numOfCandles+1:end,2) - matrix(end-numOfCandles:end-1,4));
distLC = abs(matrix(end-numOfCandles+1:end,3) - matrix(end-numOfCandles:end-1,4));

trueRange = max([distHL distHC distLC],[],2);
numAvg = mean(trueRange);


end

