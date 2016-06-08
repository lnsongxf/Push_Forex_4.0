classdef ValuesVector_real < handle
    properties
        timeInterval;
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
        function obj = ValuesVector_real(mVal)
            obj.matrixVal       = mVal;
        end
        
    end
    
end

