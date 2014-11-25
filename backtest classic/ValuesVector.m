classdef ValuesVector < handle
    properties
        timeInterval;
    end
    properties(SetAccess = protected)
        matrixVal;
    end
    methods
        
        function set.matrixVal(obj,matrix)
            obj.matrixVal = matrix;
        end
        
        function val = getSingleValue(obj,index)
            array = obj.matrixVal(index,:);
            val = SingleValue(array);
        end
        function val = getFirstValue(obj)
            array = obj.matrixVal(1,:);
            val = SingleValue(array);
        end
        function val = getLastValue(obj)
            l = length(obj.matrixVal);
            array = obj.matrixVal(l,:);
            val = SingleValue(array);
        end
        function val = getPrevValue(obj)
            l = length(obj.matrixVal);
            array = obj.matrixVal(l-1,:);
            val = SingleValue(array);
        end
        function vect = getClosureVect(obj)
            l = length(obj.matrixVal);
            vect = zeros(1,l);
            for i = 1 : l
               vect(i) = obj.getSingleValue(i).close;
            end
        end
    
        function vect = getHourVolumes(obj)
            divisor = 60/obj.timeInterval;
            l = floor(length(obj.matrixVal)/(divisor));
            module  = mod(length(obj.matrixVal),divisor);
            vect = zeros(1,l);
            
            for i = 1 : l
               tempVal = 0;
               for j = 1 : divisor
                  tempVal = tempVal + obj.getSingleValue((i-1)*divisor + j).vol;
               end
               vect(i) = tempVal;
            end
            
            tempVal = 0;
            for j = 1 : module
                  tempVal = tempVal + obj.getSingleValue(l*divisor + j).vol;
            end
            tempVal = divisor/module*tempVal;
            vect(l+1) = tempVal;
        end    
        function obj = ValuesVector(sIndex,fIndex,history)
            if(isempty(obj.matrixVal) == 0)
                clear matrixValue;    
            end
            obj.matrixVal       = history.matrixVal(sIndex:fIndex,:);
            obj.timeInterval    = history.timeInterval;
        end
    end
    
end

