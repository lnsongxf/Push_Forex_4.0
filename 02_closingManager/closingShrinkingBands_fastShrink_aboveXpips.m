function [TakeProfitPrice,StopLossPrice,newTakeP,newStopL,dynamicOn] = closingShrinkingBands_fastShrink_aboveXpips(OpenPrice,LastClosePrice,direction,TakeP,StopL, ~, dynamicParameters)

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
% If the current gain ($$) is above min_gain, then shrink SL faster
% ---------------------------------------------------


% ShrinkAdded sets how much to reduce the SL at every new step
ShrinkTP      = dynamicParameters {1};
ShrinkSL      = dynamicParameters {2};
speedFactorSL = dynamicParameters {3};
min_gain = 100;

% MeanPrice is the mid value between TP and SL
MeanPrice = floor( (TakeProfitPrice + StopLossPrice) / 2 );

distance = direction * ( LastClosePrice - MeanPrice );

current_gain = direction * ( LastClosePrice - OpenPrice );

if ( distance > 0 )
    
    if ( current_gain < min_gain )
        
        StopLossPrice = StopLossPrice + direction * ( distance + ShrinkSL );
        TakeProfitPrice = TakeProfitPrice + direction * ( distance - ShrinkTP );
        
        newStopL = StopL - ( distance + ShrinkSL );
        newTakeP = TakeP + ( distance - ShrinkTP );
        
        display(strcat('dynamical shrinking bands: TP = ',num2str(newTakeP),' SL = ',num2str(newStopL)));
        
        dynamicOn = 1;
        
    else
        
        StopLossPrice = StopLossPrice + direction * ( distance + speedFactorSL*ShrinkSL );
        TakeProfitPrice = TakeProfitPrice + direction * ( distance - ShrinkTP );
        
        newStopL = StopL - ( distance + speedFactorSL*ShrinkSL );
        newTakeP = TakeP + ( distance - ShrinkTP );
        
        display(strcat('faster dynam shrinking bands: TP = ',num2str(newTakeP),' SL = ',num2str(newStopL)));
        
        dynamicOn = 1;
        
    end
    
end



end