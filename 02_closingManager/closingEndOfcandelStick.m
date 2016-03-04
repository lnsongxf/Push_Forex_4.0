function [TakeProfitPrice,StopLossPrice,newTakeP,newStopL,dynamicOn] = closingEndOfcandelStick(OpenPrice,LastClosePrice,direction,~,StopL, ~, ~)

% ------------ do not modify inside -----------------
StopLossPrice   = OpenPrice - direction * StopL;
newStopL = StopL;
% ---------------------------------------------------


% ------------------IDEA BEHIND----------------------
% the function set the take profit price to the end of the candle stick. 
% ---------------------------------------------------

TakeProfitPrice = LastClosePrice;
newTakeP = abs(OpenPrice - TakeProfitPrice);

dynamicOn = 0;

end