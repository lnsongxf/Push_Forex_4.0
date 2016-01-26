function [TakeProfitPrice,StopLossPrice,newTakeP,newStopL,dynamicOn] = closingDontloose(OpenPrice,LastClosePrice,direction,TakeP,StopL, ~, dynamicParameters)

% ------------ do not modify inside -----------------
TakeProfitPrice = OpenPrice + direction * TakeP;
StopLossPrice   = OpenPrice - direction * StopL;
newTakeP = TakeP;
newStopL = StopL;
dynamicOn = 0;
% ---------------------------------------------------


% ------------------IDEA BEHIND----------------------
% If the current price allows a possible gain, reset the SL and TP price to
% some values ...
% ---------------------------------------------------


%
minTP = dynamicParameters {1};
pipsSL = dynamicParameters {2};
lateSL = dynamicParameters {3};

distance = direction * ( LastClosePrice - OpenPrice );

if newStopL ~= lateSL;
    
    if ( distance > minTP )
        
        StopLossPrice = LastClosePrice - direction * pipsSL;
        TakeProfitPrice = TakeProfitPrice + direction * minTP;
        
        
        newTakeP = (TakeProfitPrice - OpenPrice) * direction;
        
        %         newStopL = OpenPrice - StopLossPrice * direction; % wrong
        %         newStopL = (OpenPrice - StopLossPrice) * direction; % correct
        
        newStopL = lateSL;
        
        %     display(strcat('dynamical shrinking bands: TP = ',num2str(newTakeP),' SL = ',num2str(newStopL)));
        
        dynamicOn = 1;
        
    end
    
end


end