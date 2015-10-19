function [params,TakeProfitPrice,StopLossPrice] = dynamicalTPandSLManager(operationState, chiusure, params)

operationState.minutesFromOpening = operationState.minutesFromOpening + 1;
LastClosePrice = chiusure(end);
direction=operationState.actualOperation;

OpenPrice = params.get('openValue_');
TakeP = params.get('noLoose___');
StopL = params.get('stopLoss__');

TakeProfitPrice = OpenPrice + direction * TakeP;
StopLossPrice   = OpenPrice - direction * StopL;

% If the current price is more than SL above the opening prcice, re-set
if abs( (LastClosePrice - StopLossPrice) ) > abs(StopL)*4
    
    distance = floor(abs(LastClosePrice - StopLossPrice)/2);
    
    newStopL =  - direction * ( (LastClosePrice - OpenPrice) - direction * distance );
    
    params.set('stopLoss__',newStopL);
    display(strcat('dynamical SL, the new SL is',' ',num2str(newStopL)));
    
    StopLossPrice    = OpenPrice - direction * newStopL;
    
end

% If the current price is above half TakeP, re-set the StopL and TakeP
if ( (LastClosePrice - TakeProfitPrice) * direction ) >= 0
    
    newTakeP = TakeP + 4 + abs(LastClosePrice - TakeProfitPrice);
    params.set('noLoose___',newTakeP);
    
    TakeProfitPrice = OpenPrice + direction * newTakeP;
    
    newStopL = - TakeP + 2;
    params.set('stopLoss__',newStopL);
    display(strcat('dynamical TP = ',num2str(newTakeP),'/','dynamical SL = ',num2str(newStopL)));
    
    StopLossPrice    = OpenPrice - direction * newStopL;

end

end

