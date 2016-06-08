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
% some values according to the dynamicParameters (the idea is that SL will be 0 or negative!)
% ---------------------------------------------------


%
minTP = dynamicParameters {1};  % qui e' sia il minimo guadagno richiesto che il num di pips di cui aumenti il TP

% distance is related to the SL price (it should be always positive)
distance = direction * ( LastClosePrice - OpenPrice );


if ( distance > minTP && StopL > 0)   % se SL e' ancora positivo
    
    StopLossPrice = OpenPrice;
    TakeProfitPrice = TakeProfitPrice + direction * minTP;
    
    
    newTakeP = (TakeProfitPrice - OpenPrice) * direction;
    
    %         newStopL = OpenPrice - StopLossPrice * direction; % wrong
    
        
    newStopL = min( (OpenPrice - StopLossPrice) * direction , StopL );

    
    %              display(strcat('dynamical shrinking bands: TP = ',num2str(newTakeP),' SL = ',num2str(newStopL)));
    
    dynamicOn = 1;
    
end


end