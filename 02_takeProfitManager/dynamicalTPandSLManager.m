function params = dynamicalTPandSLManager(operationState, chiusure, params) 

    LastClosePrice = chiusure(end);
    OpenPrice = params.get('openValue_');
    TakeP = params.get('noLoose___');
    StopL = params.get('stopLoss__');
    %TakeProfitPrice = OpenPrice + operationState.actualOperation*TakeP;
    StopLossPrice = OpenPrice - operationState.actualOperation*StopL;
    
    % If the current price is above half TakeP, re-set the StopL and TakeP
    %if abs( (LastClosePrice - TakeProfitPrice) ) < (TakeP/2)
    
    % If the current price is more than SL above the opening prcice, re-set 
    if abs( (LastClosePrice - StopLossPrice) ) > abs(StopL)*2
        
        newStopL = -floor(abs(LastClosePrice - OpenPrice)/2);
        %newTakeP = TakeP;
                            
        params.set('stopLoss__',newStopL);
        display('dynamical SL');
        
        %params.set('noLoose___',newTakeP);
        
    end

end