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
        openTicket;
        closeTicket;
        
        
        tElapsedOpeningRequest;
        tElapsedClosingRequest;
        
    end
    
end