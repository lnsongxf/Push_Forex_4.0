classdef Algorithm < handle
    
    properties
        params;
        history;
        operStates;
        actIndex;
        deltaIndex;
        startingIndex;
        operations;
        actOper;
        optimize;
    end
    methods(Abstract)
        setParameter(obj,deltaIndex,startIndex,paramsStruct);
        optimization(obj);
        lifeCicle(obj,values);
        controlFinished(obj);
    end
    methods
        
        function obj = loadOnStartup(obj,time,cross,delta,start,paramsStruct)
            obj.history = History(cross);
            if(time > 0)
                obj.history.timeInterval = time;
            end
            obj.history.loadHistory;
            obj.setParameter(delta,start,paramsStruct);
            obj.optimized = 0;
            clear paramsStruct;
        end
        
        
        function spin(obj,~)
            finished = 0;
            obj.actIndex = obj.startingIndex;
            while(finished == 0)
                values = obj.buildVectValues;
                if(obj.optimize > 0)
                    obj.optimization;
                    if obj.params.optimized == 1
                        if obj.actOper.type == 0
                            obj.params.updateValues;
                            obj.params.optimized = 0;
                        end
                    end
                end
                if obj.params.working
                    obj.lifeCicle(values);
                end
                obj.updateEarnings;
                obj.updateIndex;
                finished = obj.controlFinished;               
                clear values;
            end
            obj.closeOperation;
        end
        function values = buildVectValues(obj)
            values = ValuesVector(obj.actIndex,obj.actIndex+obj.deltaIndex-1,obj.history);
        end
        function obj = updateIndex(obj)
           obj.actIndex = obj.actIndex+1; 
        end
        function obj = updateEarnings(obj)
           if(obj.actOper.valueOpen == 0)
               %apri posizione
               if(abs(obj.operStates.actualOperation) == 1)
                   
                   obj.actOper.type     = obj.operStates.actualOperation;
                   obj.actOper.valueOpen= obj.params.get('openValue_');
                    %obj.actOper.stdDev= obj.params.get('stdDev____');
                    %obj.actOper.deltaBinary= obj.params.get('deltaBinar');
                   obj.actOper.index = obj.actIndex;
                   %display(strcat('Operazione aperta al valore: ',num2str(obj.actOper.valueOpen)));
                   %display(strcat('Direzione: ',num2str(obj.actOper.type)));
               end
           else
               %chiudi posizione
               if(abs(obj.operStates.actualOperation) == 0)
                   obj.actOper.valueClose   = obj.params.get('closeValue');
                   %display(strcat('Operazione chiusa al valore: ',num2str(obj.actOper.valueClose)));
                   %display(strcat('Guadagno in questa singola operazione: ',num2str(obj.actOper.earnCalculation)));
                   %e aggiorna le vincite
                   obj.operations.addOperation(obj.actOper);
                   clear obj.actOper;
                   obj.actOper = SingleOperation;
                   obj.operations.totalEarning = 0;
                   %subplot(2,1,2);
                   %plot(obj.operations.cumSumRet);
                   pause(1);
                   modifyStructure(obj);
               else
                   obj.actOper.duration = obj.actOper.duration + 1;
               end
           end
        end
        
        function obj = closeOperation(obj)
            if(abs(obj.operStates.actualOperation) == 1)
                obj.actOper.valueClose   = obj.params.get('closeValue');
                if(obj.actOper.valueClose <= 0)
                    v = obj.buildVectValues.getClosureVect;
                    obj.actOper.valueClose = v(end);
                end
                %display(strcat('Operazione chiusa al valore: ',num2str(obj.actOper.valueClose)));
                %display(strcat('Guadagno in questa singola operazione: ',num2str(obj.actOper.earnCalculation)));
                %e aggiorna le vincite
                obj.operations.addOperation(obj.actOper);
                clear obj.actOper;
                obj.actOper = SingleOperation;
                obj.operations.totalEarning = 0; 
                %subplot(2,1,2);  
                %plot(obj.operations.cumSumRet); 
                pause(1);
            end
        end
    end
end


%{
    methods(Access = private)
        function controlParamsLength(obj,params)
           e = MException('','La funzione non è definita perchè siamo nella classe astratta');
           throw(e); 
        end
        
        function controlParamsCoherence(params)
           e = MException('','La funzione non è definita perchè siamo nella classe astratta');
           throw(e); 
        end
    end
    %}
