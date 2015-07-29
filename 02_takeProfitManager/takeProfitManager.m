function [operationState, chiusure, params] = takeProfitManager ( operationState, chiusure, params)

LastClosePrice = chiusure(end);

% display (value);
% display (params.get('openValue_'));
% display (params.get('noLoose___'));
% display (params.get('stopLoss__'));

% d = calcIndicator (params,valuesVector);
% cond5 = sign (d) ~= operationState.actualOperation;
% s = simulate (valuesVector,params);
% prev  = valuesVector.getPrevValue;
% cond5 = 0;
% if (s > params.startValue)
%    cond5 = sign (value.close-prev.close) == sign (operationState.actualOperation)*-1;
% end
% cond5 = sign (d) ~= operationState.actualOperation && abs(LastClosePrice - params.operOpeningValue) > params.stopLoss;

cond1 = abs ( LastClosePrice - params.get('openValue_')) >= params.get('noLoose___');
cond2 = sign (LastClosePrice - params.get('openValue_')) == sign (operationState.actualOperation);
cond3 = abs (LastClosePrice - params.get('openValue_')) >= params.get('stopLoss__');
cond4 = sign (LastClosePrice - params.get('openValue_')) == sign (operationState.actualOperation)*-1;

if (cond1 + cond2 == 2)
    
	operationState = params.close(operationState,LastClosePrice);
    display('win');
    % operationState = params.updatePh0To1(operationState,LastClosePrice);
    
elseif (cond3 + cond4 == 2)
    
    operationState = params.updateOnStopLoss(operationState);
    display('loose');
<<<<<<< Updated upstream
% elseif (cond5 == 1)
    % s = simulate (valuesVector,params);
    % if (s > params.get('startValue'));
    %    operationState = params.updateOnChangeIndicator(operationState,value.close);
    % end
    
=======
>>>>>>> Stashed changes
else
    
    operationState.counter = operationState.counter + 1;
    
end

end

