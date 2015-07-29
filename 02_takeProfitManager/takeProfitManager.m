function [operationState, chiusure, params] = takeProfitManager ( operationState, chiusure, params)

LastClosePrice = chiusure(end);

cond1 = abs ( LastClosePrice - params.get('openValue_')) >= params.get('noLoose___');
cond2 = sign (LastClosePrice - params.get('openValue_')) == sign (operationState.actualOperation);
cond3 = abs (LastClosePrice - params.get('openValue_')) >= params.get('stopLoss__');
cond4 = sign (LastClosePrice - params.get('openValue_')) == sign (operationState.actualOperation)*-1;

if (cond1 + cond2 == 2)
    
	operationState = params.close(operationState,LastClosePrice);
    display('win');
    
elseif (cond3 + cond4 == 2)
    
    operationState = params.updateOnStopLoss(operationState);
    display('loose');

else
    
    operationState.counter = operationState.counter + 1;
    
end

end

