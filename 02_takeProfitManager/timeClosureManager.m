function [operationState, chiusure, params] = timeClosureManager (operationState, chiusure, params, minutesForClosing)

operationState.minutesFromOpening = operationState.minutesFromOpening +1;
%display(operationState.minutesFromOpening);
LastClosePrice = chiusure(end);

if (operationState.minutesFromOpening == minutesForClosing)
    operationState = params.closeOnCall(operationState,LastClosePrice);
end

end