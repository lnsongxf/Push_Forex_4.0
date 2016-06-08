function [TakeProfitPrice,StopLossPrice,newTakeP,newStopL,dynamicOn] = closingAfterReachedTP(OpenPrice,LastClosePrice,direction,TakeP,StopL, ~, dynamicParameters)

% ------------ do not modify inside -----------------
TakeProfitPrice = OpenPrice + direction * TakeP;
StopLossPrice   = OpenPrice - direction * StopL;
newTakeP = TakeP;
newStopL = StopL;
dynamicOn = 0;
% ---------------------------------------------------


% ------------------IDEA BEHIND----------------------
% If the price already passed the TakeProfitPrice, set another goal
% ---------------------------------------------------


% ShrinkAdded sets how much to reduce the SL at every new step
TPshrinker = dynamicParameters {1}; % factor to shrink
SLshrinker = dynamicParameters {2};

% if you passed the TakeProfitPrice:
if ( ( LastClosePrice - TakeProfitPrice ) * direction > 0 )
    
    StopLossPrice =   LastClosePrice - floor( direction * abs(LastClosePrice - OpenPrice) / SLshrinker ) ;
    TakeProfitPrice = LastClosePrice + floor( direction * abs(LastClosePrice - OpenPrice) / TPshrinker ) ;
    
    newStopL = - abs( StopLossPrice - OpenPrice );
    newTakeP = abs( TakeProfitPrice - OpenPrice );
    
%     display(strcat('dynamical closing after reaching TP : TP = ',num2str(newTakeP),' SL = ',num2str(newStopL)));
    dynamicOn = 1;
    
end


end