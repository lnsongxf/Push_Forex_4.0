classdef machineStateManager < handle
    
    properties
        
        statusNotification;
        machineStatus;
        lastOperation;
        lastOpenValue;
        lastCloseValue;
        stopLoss;
        takeProfit;
        minReturn;
        lastTicket;
        
        tElapsedOpeningRequest;
        tElapsedClosingRequest;
        
    end
    
end