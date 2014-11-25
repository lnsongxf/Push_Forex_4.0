classdef AlgorithmAle < AlgorithmFake
    
    methods
        function setParameter(obj,deltaIndex,startIndex,paramsStruct)
            obj.counter = 0;
            
            obj.deltaIndex      = deltaIndex;
            obj.startingIndex   = startIndex;
            obj.params          = Parameters;
            
            
            pMap = optGui(paramsStruct);
            obj.params.setMap(pMap);
  
            obj.operStates  = OperationState;
            obj.operations  = Operations;
            obj.actOper     = SingleOperationAle;
            obj.optimize    = 1;
            obj.opt.struct  = paramsStruct;
            
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
                    display(strcat('Operazione aperta al valore: ',num2str(obj.actOper.valueOpen)));
                    display(strcat('Direzione: ',num2str(obj.actOper.type)));
                end
            else
                %chiudi posizione
                if(abs(obj.operStates.actualOperation) == 0)
                    obj.actOper.valueClose   = obj.params.get('closeValue');
                    obj.actOper.real         = obj.params.get('real______');
                    display(strcat('Operazione chiusa al valore: ',num2str(obj.actOper.valueClose)));
                    display(strcat('Guadagno in questa singola operazione: ',num2str(obj.actOper.earnCalculation)));
                    %e aggiorna le vincite
                    obj.operations.addOperation(obj.actOper);
   
                    obj.params.set('lastOper__',obj.actOper);
                    
                    clear obj.actOper;
                    obj.actOper = SingleOperationAle;
                    obj.operations.totalEarning = 0;
                    %subplot(2,1,2);
                    if (mod(length(obj.operations.array),500) == 0)
                        %plot(obj.operations.cumSumRet);
                        %pause(.1);
                    end
                    modifyStructure(obj);
                else
                    obj.actOper.duration = obj.actOper.duration + 1;
                end
            end
        end
        
        
    end
end