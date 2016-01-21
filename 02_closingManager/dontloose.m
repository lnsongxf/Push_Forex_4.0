function [TakeProfitPrice,StopLossPrice,newTakeP,newStopL,dynamicOn] = dontloose(OpenPrice,LastClosePrice,direction,TakeP,StopL, ~, dynamicParameters)

% ------------ do not modify inside -----------------
TakeProfitPrice = OpenPrice + direction * TakeP;
StopLossPrice   = OpenPrice - direction * StopL;
newTakeP = TakeP;
newStopL = StopL;
dynamicOn = 0;
% ---------------------------------------------------


% ------------------IDEA BEHIND----------------------
% If the current price allows a possible gain, reset the SL price
% very close so you don't loose money
% ---------------------------------------------------


% 
minTP = dynamicParameters {1};
pipsSL = dynamicParameters {2};

distance = direction * ( LastClosePrice - OpenPrice );

if ( distance > minTP )
    
    StopLossPrice = LastClosePrice - direction * pipsSL;
    TakeProfitPrice = TakeProfitPrice + direction * minTP;
    
    newStopL = OpenPrice - StopLossPrice * direction;
    newTakeP = (TakeProfitPrice - OpenPrice) * direction;
    
%     display(strcat('dynamical shrinking bands: TP = ',num2str(newTakeP),' SL = ',num2str(newStopL)));
    
    dynamicOn = 1;
    
end


end