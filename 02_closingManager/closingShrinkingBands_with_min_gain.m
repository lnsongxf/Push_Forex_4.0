function [TakeProfitPrice,StopLossPrice,newTakeP,newStopL,dynamicOn] = closingShrinkingBands_with_min_gain(OpenPrice,LastClosePrice,direction,TakeP,StopL, ~, dynamicParameters)

% ------------ do not modify inside -----------------
TakeProfitPrice = OpenPrice + direction * TakeP;
StopLossPrice   = OpenPrice - direction * StopL;
newTakeP = TakeP;
newStopL = StopL;
dynamicOn = 0;
% ---------------------------------------------------


% ------------------IDEA BEHIND----------------------
% This one follows the spot price by adjusting the SL and TP every time
% there is a possible gain, reducing the distance btw them gradually.
% If the current gain ($$) is above min_gain, then you can't loose money
% (and the bands will shrink a lot)
% ---------------------------------------------------


% ShrinkAdded sets how much to reduce the SL at every new step
ShrinkTP = dynamicParameters {1};
ShrinkSL = dynamicParameters {2};
min_gain = 20;

% MeanPrice is the mid value between TP and SL
MeanPrice = floor( (TakeProfitPrice + StopLossPrice) / 2 );

distance = direction * ( LastClosePrice - MeanPrice );

if ( distance > 0 )
    
    StopLossPrice = StopLossPrice + direction * ( distance + ShrinkSL );
    TakeProfitPrice = TakeProfitPrice + direction * ( distance - ShrinkTP );
    
    newStopL = StopL - ( distance + ShrinkSL );
    newTakeP = TakeP + ( distance - ShrinkTP );
    
    display(strcat('dynamical shrinking bands: TP = ',num2str(newTakeP),' SL = ',num2str(newStopL)));
    
    dynamicOn = 1;
    
end

current_gain = direction * ( LastClosePrice - OpenPrice );

if ( current_gain > min_gain && newStopL > 0)
    
    StopLossPrice = LastClosePrice - direction * min_gain ;
    TakeProfitPrice = LastClosePrice + direction * min_gain ;
    
    newStopL = - direction * ( StopLossPrice - OpenPrice ) ;
    newTakeP = direction * ( TakeProfitPrice - OpenPrice ) ;
    
    display('no Loose!');
    
end



end