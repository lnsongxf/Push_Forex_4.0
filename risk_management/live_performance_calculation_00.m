%%input
% - algoId
% - timeFrame
% - cross
function live_performance_calculation_00(algoId, timeFrame, cross)
    m = fromWebPageToMatrix(algoId, timeFrame, 'Trades.csv');
    perf = Performance_07;
    perf.calcSinglePerformance(num2str(algoId), 'demo', '', cross, timeFrame, 0, 10000, 1, m, 0)
    perf.serialize(strcat(num2str(algoId), '_performance.csv'));
end