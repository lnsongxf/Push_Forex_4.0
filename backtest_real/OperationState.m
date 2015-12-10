classdef OperationState
    
    properties
        actualOperation;
        closeRightNow;
        phase;
        lastOperation;
        lock;
        lockDuration;
        latency;
    end
    
    methods
        function obj = OperationState
            obj.actualOperation     = 0;
            obj.closeRightNow       = 0;
            obj.phase               = 0;
            obj.lastOperation       = 0;
            obj.lock                = 0;
            obj.lockDuration        = 0;
            obj.latency             = 0;
        end
    end
    
end

