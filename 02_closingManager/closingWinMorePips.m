function [TakeProfitPrice,StopLossPrice,newTakeP,newStopL,dynamicOn] = closingWinMorePips(OpenPrice,LastClosePrice,direction,TakeP,StopL, ~, dynamicParameters)

% ------------ do not modify inside -----------------
TakeProfitPrice = OpenPrice + direction * TakeP;
StopLossPrice   = OpenPrice - direction * StopL;
newTakeP = TakeP;
newStopL = StopL;
dynamicOn = 0;
% ---------------------------------------------------


% ------------------IDEA BEHIND----------------------
% If the price already passed the TakeProfitPrice, set another TP and SL
% price X pips above/below the current price
% ---------------------------------------------------


% Set how many pips to add to SL and TP
pipsTP = dynamicParameters {1};
pipsSL = dynamicParameters {2};

% if you passed the TakeProfitPrice:
if ( ( LastClosePrice - TakeProfitPrice ) * direction > 0 )
    
    StopLossPrice =   LastClosePrice - floor( direction * pipsSL ) ;
    TakeProfitPrice = LastClosePrice + floor( direction * pipsTP ) ;
    
    newStopL = - abs( StopLossPrice - OpenPrice );
    newTakeP = abs( TakeProfitPrice - OpenPrice );
    
%     display(strcat('dynamical closing after reaching TP : TP = ',num2str(newTakeP),' SL = ',num2str(newStopL)));
    dynamicOn = 1;
    
end


end