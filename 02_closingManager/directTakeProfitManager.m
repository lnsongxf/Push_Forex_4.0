function [operationState, chiusure, params] = directTakeProfitManager (operationState, chiusure, params,TakeProfitPrice,StopLossPrice)

operationState.minutesFromOpening = operationState.minutesFromOpening + 1;
LastClosePrice = chiusure(end);

condTP = (sign(LastClosePrice - TakeProfitPrice)*operationState.actualOperation);
condSL = (sign(StopLossPrice - LastClosePrice))*operationState.actualOperation;

if condTP >= 0
    
	operationState = params.closeOnCall(operationState,LastClosePrice);
   display('position closed becasue of reached TP');
    
elseif condSL >= 0
    
    operationState = params.closeOnCall(operationState,LastClosePrice);
    display('position closed becasue of reached SL');
end

end
