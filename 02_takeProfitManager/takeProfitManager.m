function [operationState, chiusure, params] = takeProfitManager ( operationState, chiusure, params)

termUp = chiusure(end);
termDw = chiusure(end);

% display (value);
% display (params.get('openValue_'));
% display (params.get('noLoose___'));
% display (params.get('stopLoss__'));

% d = calcIndicator (params,valuesVector);
% cond3 = sign (d) ~= operationState.actualOperation;
% s = simulate (valuesVector,params);
% prev  = valuesVector.getPrevValue;
% cond3 = 0;
% if (s > params.startValue)
%    cond3 = sign (value.close-prev.close) == sign (operationState.actualOperation)*-1;
% end
% cond3 = sign (d) ~= operationState.actualOperation && abs(termDw - params.operOpeningValue) > params.stopLoss;
cond1 = abs ( termUp - params.get('openValue_')) >= params.get('noLoose___');
cond2 = sign (termUp - params.get('openValue_')) == sign (operationState.actualOperation);
if (cond1+cond2 == 2)
	operationState = params.close(operationState,termUp);
    display('win');
    % operationState = params.updatePh0To1(operationState,termUp);
elseif (abs (termDw - params.get('openValue_')) >= params.get('stopLoss__') && sign (termDw - params.get('openValue_')) == sign (operationState.actualOperation)*-1)
    operationState = params.updateOnStopLoss(operationState);
    display('loose');
% elseif (cond3 == 1)
    % s = simulate (valuesVector,params);
    % if (s > params.get('startValue'));
    %    operationState = params.updateOnChangeIndicator(operationState,value.close);
    % end
else
    operationState.counter = operationState.counter + 1;
end

end

