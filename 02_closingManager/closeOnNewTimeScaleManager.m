function [operationState, chiusure, params] = closeOnNewTimeScaleManager (operationState, chiusure, params)
   
operationState.minutesFromOpening = operationState.minutesFromOpening +1;
LastClosePrice = chiusure(end-1);

% display(['currentvalue = ', num2str(LastClosePrice),' openvalue =', num2str(params.get('openValue_')), ...
%     ' op state =', num2str(operationState.actualOperation)]) ;

cond1 = abs (LastClosePrice - params.get('openValue_')) >= params.get('noLoose___');
cond2 = sign (LastClosePrice - params.get('openValue_')) == sign (operationState.actualOperation);
cond3 = abs (LastClosePrice - params.get('openValue_')) >= params.get('stopLoss__');
cond4 = sign (LastClosePrice - params.get('openValue_')) == sign (operationState.actualOperation)*-1;

if (cond1 + cond2 == 2)
    
	operationState = params.closeOnCall(operationState,LastClosePrice);
    display('win');
    
elseif (cond3 + cond4 == 2)
    
    operationState = params.closeOnCall(operationState,LastClosePrice);
    display('loose');
end

end

