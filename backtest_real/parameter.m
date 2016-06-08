classdef parameter < handle

    properties
        startValue
        optimize
        range
        delta
        oldValue
    end
    
    
    methods
        function obj = setValue(obj,value)
            obj.startValue = value;
        end
        function obj = setOldValue(obj,value)
            obj.oldValue = value;
        end
    end

end