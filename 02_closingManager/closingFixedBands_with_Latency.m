function [TakeProfitPrice,StopLossPrice,newTakeP,newStopL,dynamicOn] = closingFixedBands_with_Latency(OpenPrice,LastClosePrice,direction,TakeP,StopL,Latency, dynamicParameters)

% ------------ do not modify inside -----------------
TakeProfitPrice = OpenPrice + direction * TakeP;
StopLossPrice   = OpenPrice - direction * StopL;
newTakeP = TakeP;
newStopL = StopL;
dynamicOn = 0;
% ---------------------------------------------------

% ------------------IDEA BEHIND----------------------
% This one follows the spot price by adjusting the SL and TP every time
% there is a possible gain. The latency shrinks the TP/SL by an equal
% amount
% ---------------------------------------------------

% ShrinkAdded sets how much to reduce the SL at every new step
ShrinkLatency = dynamicParameters {1};

% MeanPrice is the mid value between TP and SL
MeanPrice = floor( (TakeProfitPrice + StopLossPrice) / 2 );

distance = direction * ( LastClosePrice - MeanPrice );

if ( distance > 0 )
    
    StopLossPrice = StopLossPrice + direction * distance;
    TakeProfitPrice = TakeProfitPrice + direction * distance;
    
    newStopL = StopL - distance;
    newTakeP = TakeP + distance;
    
    display(strcat('dynamical bands: TP = ',num2str(newTakeP),' SL = ',num2str(newStopL)));
    
    dynamicOn = 1;
    Latency = 0;
    
end

if ( Latency > 100 )
    
    StopLossPrice = StopLossPrice + direction * ShrinkLatency;
    TakeProfitPrice = TakeProfitPrice - direction * ShrinkLatency;
    
    newStopL = StopL - ShrinkLatency;
    newTakeP = TakeP - ShrinkLatency;
    
    display(strcat('shrinking latency: TP = ',num2str(newTakeP),' SL = ',num2str(newStopL)));
    
    dynamicOn = 1;
    
end

end