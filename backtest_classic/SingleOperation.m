classdef SingleOperation
    %OPERATIONS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        type = 0;
        valueOpen = 0;
        valueClose = 0;
        duration;
        stdDev = 0;
        deltaBinary = 0;
        index = 0;
    end
    
    methods
        function earns = earnCalculation(obj)
            earns = 'undefined';
            if(obj.valueClose >= 0 && obj.valueOpen >= 0 && abs(obj.type)>0)
                earns = (obj.valueClose - obj.valueOpen)*sign(obj.type);
            end
        end
        function obj = SingleOperation
            obj.type = 0;
            obj.valueOpen = 0;
            obj.valueClose = 0;
            obj.duration = 0;
            obj.stdDev = 0;
            obj.deltaBinary = 0;
            obj.index = 0;
        end
    end
    
end

