classdef DecisionMaker_mean < handle
    
    properties
        init;
        real;
        direction;
    end
    
    
    methods
        
        % funzione per entrar o uscire da un'operazione a seconda di quanto
        % l'ultima chiusura si discosta dalla media di n chiusure storiche
        % precedenti (potrei anche metter Nsigma in input)
        function [operationState,counter] = decisionMeanSdev (obj,closurePrices,params,operationState)
     
            p=closurePrices;
            
            media = mean(p);
            stdev = std(p);
            currValue = p(end);

            %di quante stdev si deve discostare currValue per suggerire compra o vendi 
            Nsigma = 1;
            
            if currValue > media + Nsigma*stdev
                obj.direction = 1;
            elseif currValue < media - Nsigma*stdev
                obj.direction = -1;
            else
                obj.direction = operationState.lastOperation;
            end
            
            
            
            operationState.actualOperation = obj.direction;
            
            params.set('openValue_',currValue);
            params.set('closeValue',-1);
            
          
            params.set('maxPercTp_',1);
            params.set('initPercTp',1);
            params.set('real______',obj.real);
            
            counter = 0;
    
        end
        
            
    end
        
end