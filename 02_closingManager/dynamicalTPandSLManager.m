function [params,TakeProfitPrice,StopLossPrice,dynamicOn] = dynamicalTPandSLManager(operationState, chiusure, params, closingFunction,dynamicParameters)

LastClosePrice = chiusure(end);
direction = operationState.actualOperation;
Latency   = operationState.latency;

OpenPrice = params.get('openValue_');
TakeP = params.get('noLoose___');
StopL = params.get('stopLoss__');

[TakeProfitPrice,StopLossPrice,newTakeP,newStopL,dynamicOn] = closingFunction(OpenPrice,LastClosePrice,direction,TakeP,StopL,Latency, dynamicParameters);

params.set('noLoose___',newTakeP);
params.set('stopLoss__',newStopL);

end

