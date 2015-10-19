function [params,TakeProfitPrice,StopLossPrice] = dynamicalTPandSLManager(operationState, chiusure, params)

operationState.minutesFromOpening = operationState.minutesFromOpening + 1;
LastClosePrice = chiusure(end);

OpenPrice = params.get('openValue_');
TakeP = params.get('noLoose___');
StopL = params.get('stopLoss__');

TakeProfitPrice = OpenPrice + operationState.actualOperation*TakeP;
StopLossPrice   = OpenPrice - operationState.actualOperation*StopL;

% If the current price is above half TakeP, re-set the StopL and TakeP
if TakeProfitPrice
    
    newTakeP = TakeP;
    
    params.set('noLoose___',newTakeP);
    %display('dynamical TP');
    
    TakeProfitPrice = OpenPrice + operationState.actualOperation*newTakeP;
    
end

% If the current price is more than SL above the opening prcice, re-set
if abs( (LastClosePrice - StopLossPrice) ) > abs(StopL)*1.2
    
    newStopL = -floor(abs(LastClosePrice - OpenPrice)/2);
    
    params.set('stopLoss__',newStopL);
    display('dynamical SL');
    
    StopLossPrice    = OpenPrice - operationState.actualOperation*newStopL;
    
end

end

