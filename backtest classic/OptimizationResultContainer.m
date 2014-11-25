classdef OptimizationResultContainer < handle
   
    properties (SetAccess = protected)
       vettore 
    end
    
    
    
    methods
        function obj = OptimizationResultContainer(dimension)
            
            for i = 1 : dimension
               appVett(i) = OptimizationResult(0,1);
            end
            obj.vettore = appVett;
        end
        
        function val = get(obj,i)
            val = obj.vettore(i); 
        end
        
        function set(obj,i,val)
            obj.vettore(i) = val;
        end
        
        function l = numberOfValues(obj)
            l = length(obj.vettore);
        end
    end
    
end