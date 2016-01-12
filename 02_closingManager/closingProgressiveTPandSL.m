function [newTakeP,newStopL] = closingProgressiveTPandSL (LastClosePrice,OpenPrice,TakeProfitPrice,StopLossPrice,direction,TakeP,StopL,variables)

tresholdSL = variables(1);
newLimitTP = variables(2);
newLimitSL = variables(3);

newTakeP = TakeP;
newStopL = StopL;

% If the current price is more than SL above the opening prcice, re-set
if abs( (LastClosePrice - StopLossPrice) ) > abs(StopL) * tresholdSL
    
    distance = floor(abs(LastClosePrice - StopLossPrice)/2);
    
    newStopL =  - direction * ( (LastClosePrice - OpenPrice) - direction * distance );
    
end

% If the current price is above half TakeP, re-set the StopL and TakeP
if ( (LastClosePrice - TakeProfitPrice) * direction ) >= 0
    
    newTakeP = TakeP + abs(LastClosePrice - TakeProfitPrice) + newLimitTP;

    newStopL = - TakeP + newLimitSL;

end