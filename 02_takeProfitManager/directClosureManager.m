function [operationState, chiusure, params] = directClosureManager (operationState, chiusure, params)

LastClosePrice = chiusure(end);

if (operationState.closeRightNow == 1)
    operationState = params.closeOnCall(operationState,LastClosePrice);
else
    operationState.counter = operationState.counter + 1;
end

end
