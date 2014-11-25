classdef OptimizationResult < handle
    
    properties
        parametersValues;
        parametersRanges;
        forecasting;
        earning;
        array;
        finished;
        backupArray;
    end
    
    methods
        function obj = OptimizationResult(parValues, parRanges)
            obj.parametersValues = parValues;
            obj.parametersRanges = parRanges;
        end
        
        function obj = saveResult(obj)
            obj.backupArray = obj.array;
        end
        function addResult(obj,res)
            
            obj.array = obj.backupArray;
            
            if(isempty(obj.array))
                
                obj.array = res;
            else
                l = length(obj.array);
                if(l < 1)
                    obj.array(:,l+1) = res';
                else
                    tempArray = zeros(size(obj.array));
                    for i = 2 : length(obj.array(1,:))
                       tempArray(:,i-1) = obj.array(:,i); 
                    end
                    tempArray(:,l) = res;
                    obj.array = tempArray;
                end
            end
        end
    end
    
    methods
        function obj = boundaryConditions(obj)
            obj.finished = 1;
            for k = 1 : length(obj.parametersValues)
               parVal = obj.parametersValues(k);
               parRan = obj.parametersRanges(k,:);
               if(parVal == parRan(1))
                   obj.extendRange(k,-1);
                   obj.finished = 0;
               elseif(parVal == parRan(length(parRan)))
                   obj.extendRange(k,1);
                   obj.finished = 0;
               end
            end
        end
        function extendRange(obj,index,side)
            parRan = obj.parametersRanges(index,:);
            l = length(parRan);
            amplitude = parRan(l) - parRan(1);
            newParRan = zeros(1,l);
            if(side == -1)
                startingPoint = parRan(1);
            elseif(side == 1)
                startingPoint = parRan(l);
            end
            newParRan(1) = startingPoint;
            step = amplitude / (l-1);
            for k = 2 : l
               newParRan(k) =  newParRan(k-1) + step*side;
            end
            obj.parametersRanges(index,:) = newParRan;
        end
        function mem = sumOptResult(obj,mem)
           obj.addResult(mem);
           mem = sum(obj.array,2);
        end
    end
end

