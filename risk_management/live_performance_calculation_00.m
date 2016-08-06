%%input
% - algoId
% - timeFrame
% - cross
function live_performance_calculation_00(algoId, timeFrame, cross)
    if ischar(algoId)
        algoId = str2double(algoId);
    end
    if ischar(timeFrame)
        timeFrame = str2double(timeFrame);
    end
    performance_calculation(algoId, timeFrame, cross);
    clear all;
    exit;
end
