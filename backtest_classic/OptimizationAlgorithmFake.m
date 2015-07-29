classdef OptimizationAlgorithmFake < AlgorithmFake
    
    properties
        lastIndex;
    end
    
    methods
        
        function val = controlFinished(obj)
            if(obj.actIndex + 1 > obj.lastIndex)
                val = 1;
            else
                val = 0;
            end
        end
        function obj = updateEarnings(obj)
           if(obj.actOper.valueOpen == 0)
               %apri posizione
               if(abs(obj.operStates.actualOperation) == 1)
                   obj.actOper.type     = obj.operStates.actualOperation;
                   obj.actOper.valueOpen= obj.params.get('openValue_');
               end
           else
               %chiudi posizione
               if(abs(obj.operStates.actualOperation) == 0)
                   obj.actOper.valueClose   = obj.params.get('closeValue');
                   %e aggiorna le vincite
                   obj.operations.addOperation(obj.actOper);
                   clear obj.actOper;
                   obj.actOper = SingleOperation;
               else
                   obj.actOper.duration = obj.actOper.duration + 1;
               end
           end
        end
        function obj = updateIndex(obj)
           if(mod(obj.counter,obj.history.extTimeInterval) == 0)
              obj.actIndex = obj.actIndex+1;
           end
           obj.counter = obj.counter + 1;
        end
    end
    
end

