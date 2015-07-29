function [operationState, chiusure, params] = directClosureManager (operationState, chiusure, params)

termUp = chiusure(end);
termDw = chiusure(end);

% display (value);
% display (params.get('openValue_'));
% display (params.get('noLoose___'));
% display (params.get('stopLoss__'));

d = calcIndicator (params,valuesVector);
cond3 = sign (d) ~= operationState.actualOperation;
s = simulate (valuesVector,params);
prev  = valuesVector.getPrevValue;
cond3 = 0;
if (s > params.startValue)
   cond3 = sign (value.close-prev.close) == sign (operationState.actualOperation)*-1;
end
cond3 = sign (d) ~= operationState.actualOperation && abs(termDw - params.operOpeningValue) > params.stopLoss;

if (operationState.closeRightNow == 1)
    s = simulate (valuesVector,params);
    if (s > params.get('startValue'));
       operationState = params.updateOnChangeIndicator(operationState,value.close);
    end
else
    operationState.counter = operationState.counter + 1;
end

end
