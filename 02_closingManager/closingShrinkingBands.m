function [TakeProfitPrice,StopLossPrice,newTakeP,newStopL,dynamicOn] = closingShrinkingBands(OpenPrice,LastClosePrice,direction,TakeP,StopL,dynamicParameters)

% ------------ do not modify inside -----------------
TakeProfitPrice = OpenPrice + direction * TakeP;
StopLossPrice   = OpenPrice - direction * StopL;
newTakeP = TakeP;
newStopL = StopL;
dynamicOn = 0;
% ---------------------------------------------------

% ShrinkAdded sets how much to reduce the SL at every new step
ShrinkAdded = dynamicParameters {1};

% MeanPrice is the mid value between TP and SL 
MeanPrice = floor( (TakeProfitPrice + StopLossPrice) / 2 );

distance = direction * ( LastClosePrice - MeanPrice );

if ( distance > 0 )
    
    StopLossPrice = StopLossPrice + direction * ( distance + ShrinkAdded );
    TakeProfitPrice = TakeProfitPrice + direction * distance;
    
    newStopL = StopL - ( distance + ShrinkAdded );
    newTakeP = TakeP + distance;
    
    display(strcat('dynamical bands: TP = ',num2str(newTakeP),' SL = ',num2str(newStopL)));
    
    dynamicOn = 1;
    
end


end