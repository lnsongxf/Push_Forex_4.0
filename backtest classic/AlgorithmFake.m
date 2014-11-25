classdef AlgorithmFake < Algorithm
    
    properties
        counter = 0;
        opt;
        struct;
    end
    
    methods
        function setParameter(obj,deltaIndex,startIndex,paramsStruct)
            obj.counter = 0;
            
            obj.deltaIndex      = deltaIndex;
            obj.startingIndex   = startIndex;
            obj.params          = Parameters;
            
            
            pMap = optGui(paramsStruct);
            obj.params.setMap(pMap);
            %obj.params.mapIterator = MapIterator(obj.params.map);
           
            %{
            obj.params.stopLoss         = cell2mat(paramsStruct(3));
            obj.params.smoothingCoef    = cell2mat(paramsStruct(4));
            obj.params.startValue       = cell2mat(paramsStruct(5));
            obj.params.maxPercTp        = cell2mat(paramsStruct(6));
            obj.params.initPercTp       = cell2mat(paramsStruct(7));
            obj.params.noLoose          = cell2mat(paramsStruct(8));
            obj.params.alfa             = cell2mat(paramsStruct(9));
            obj.params.newAlfa          = cell2mat(paramsStruct(10));
            obj.params.maxDelta         = cell2mat(paramsStruct(11));
            obj.params.deltaOpt         = cell2mat(paramsStruct(12));
            obj.params.maxIterOpt       = cell2mat(paramsStruct(13));
            %}
            
            obj.operStates  = OperationState;
            obj.operations  = Operations;
            obj.actOper     = SingleOperation;
            obj.optimize    = 1;
            obj.opt.struct  = paramsStruct;
            
        end
        function optimization(obj)
            if isempty(obj.opt.optimizResult)
               obj.opt.buildOptResult(length(values(obj.params.map))); 
            end
            obj.params = obj.opt.optimize(obj.params,obj.actIndex);
        end
        function obj = loadOnStartup(obj,time,cross,delta,start,paramsStruct)
            obj.history = ExtendedHistory(cross,time);
            obj.history.loadHistory;
            obj.setParameter(delta,start,paramsStruct);
            obj.opt = Optimization(obj.history);
            %%%%%%
            obj.params.working = 1;
            obj.optimize = 0;
            %%%%%%
            clear paramsStruct;
        end
        function lifeCicle(obj,values)
            [obj.operStates, ~, obj.params] = lifeCicleNew_binary(obj.operStates,values,obj.params);
        end
        function val = controlFinished(obj)
            if(obj.actIndex + 1 > obj.history.getLength)
                val = 1;
            else
                val = 0;
            end
            %if(mod(obj.actIndex,100) == 1)
            %    obj.operations.totalEarningCalculation;
            %    obj.operations.totalEarning;
            %end
        end
        function values = buildVectValues(obj)
            values = ExtValuesVector(obj.actIndex,obj.actIndex+obj.deltaIndex-1,obj.counter,obj.history);
        end
        function obj = updateIndex(obj)
           if(mod(obj.counter,obj.history.extTimeInterval) == 0)
              obj.actIndex = obj.actIndex+1;
              obj.optimize = 1;
           else
              obj.optimize = 0;
           end
           obj.counter = obj.counter + 1;
           if(mod(obj.actIndex,100) == 0)
               
           end
        end
    end
    
end

