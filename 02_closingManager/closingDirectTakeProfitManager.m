function [TakeProfitPrice,StopLossPrice,newTakeP,newStopL,dynamicOn] = closingDirectTakeProfitManager(OpenPrice,~,direction,TakeP,StopL, ~, ~)

% ------------ do not modify inside -----------------
TakeProfitPrice = OpenPrice + direction * TakeP;
StopLossPrice   = OpenPrice - direction * StopL;
newTakeP = TakeP;
newStopL = StopL;
dynamicOn = 0;
% ---------------------------------------------------


% ------------------IDEA BEHIND----------------------
% This function must to be used in combination with directTakeProfitManager
% when no dynamic closures is active. 
% ---------------------------------------------------
