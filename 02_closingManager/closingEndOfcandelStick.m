function [TakeProfitPrice,StopLossPrice,newTakeP,newStopL,dynamicOn] = closingEndOfcandelStick(OpenPrice,LastClosePrice,direction,TakeP,StopL,~, dynamicParameters)

% ------------ do not modify inside -----------------
StopLossPrice   = OpenPrice - direction * StopL;
newStopL = StopL;
% ---------------------------------------------------


% ------------------IDEA BEHIND----------------------
% the function set the take profit price to the end of the candle stick.
% ---------------------------------------------------

endOfcandelStick = dynamicParameters {1};

if endOfcandelStick == 1;
    TakeProfitPrice = LastClosePrice;
    newTakeP = abs(OpenPrice - TakeProfitPrice);
else
    TakeProfitPrice = OpenPrice + direction * TakeP;
    newTakeP = TakeP;
end

dynamicOn = 0;

end