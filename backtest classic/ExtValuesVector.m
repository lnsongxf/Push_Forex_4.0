classdef ExtValuesVector < ValuesVector
    properties
        
    end
   
    methods
            
        function obj = ExtValuesVector(sIndex,fIndex,counter,history)
            obj = obj@ValuesVector(1,fIndex-sIndex+1,history);
            clear obj.matrixValue;
            obj.matrixVal       = history.matrixVal(sIndex:fIndex,:);
            obj.matrixVal(end,:)= history.getExactValue(fIndex,counter);
            obj.timeInterval    = history.timeInterval;
        end
        function vect = getHourVolumes(obj)
            s = size(obj.matrixVal);
            m = min(s);
            vect = obj.matrixVal(:,m);
        end    
    end
    
end

