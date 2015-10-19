function [operationState, chiusure, params] = directClosureManager (operationState, chiusure, params)
    
operationState.minutesFromOpening = operationState.minutesFromOpening +1;
LastClosePrice = chiusure(end);

if (operationState.closeRightNow == 1)
    operationState = params.closeOnCall(operationState,LastClosePrice);
end

end
