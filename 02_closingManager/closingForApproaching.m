function [TakeProfitPrice,StopLossPrice,newTakeP,newStopL,dynamicOn] = closingForApproaching(OpenPrice,LastClosePrice,direction,TakeP,StopL,~, dynamicParameters)

% ------------ do not modify inside -----------------
TakeProfitPrice = OpenPrice + direction * TakeP;
StopLossPrice   = OpenPrice - direction * StopL;
newTakeP = TakeP;
newStopL = StopL;
dynamicOn = 0;
% ---------------------------------------------------

gain = dynamicParameters {1};

% ------------------IDEA BEHIND----------------------
% This one follows the spot price by adjusting the SL and TP every time
% there is a possible gain. The SL is pushed fast towards the spot price.
% The TP could be modified as well...
% ---------------------------------------------------



% If the current price is more than SL above the opening prcice, re-set
if abs( (LastClosePrice - StopLossPrice) ) > abs(StopL)*gain
    
    distance = floor(abs(LastClosePrice - StopLossPrice)/2);
    
    newStopL =  - direction * ( (LastClosePrice - OpenPrice) - direction * distance );
    
    StopLossPrice    = OpenPrice - direction * newStopL;
    
    display(strcat('dynamical SL, the new SL is ',' ',num2str(newStopL)));
    dynamicOn = 1;
    
end

% If the current price is above half TakeP, re-set the StopL and TakeP
if ( (LastClosePrice - TakeProfitPrice) * direction ) >= 0
    
    newTakeP = TakeP + 4 + abs(LastClosePrice - TakeProfitPrice);
    
    TakeProfitPrice = OpenPrice + direction * newTakeP;
    
    newStopL = - TakeP + 2;
    
    StopLossPrice    = OpenPrice - direction * newStopL;
    
    display(strcat('dynamical TP = ',num2str(newTakeP),' / ','dynamical SL = ',num2str(newStopL)));
    dynamicOn = 1;
    
end



end