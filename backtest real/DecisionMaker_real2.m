classdef DecisionMaker_real2 < handle
    
    properties
        init;
        real;
        direction;
    end
    
    
    methods
        
        %% calc Lock
        
        % funzione per la gestione del lock
        function [operationState] = calcLock(obj,operationState)
            operationState.lockDuration = 0;
        end
        
        
        
        
        %% decision Real
        
        %NOTE: funzione per gestire l'avvio e la terminazione del processo
        % parallelo a partire da delle condizioni sui pattern dei ritorni
        
        function obj = decisionReal1 (obj,returns)
            
            if obj.init ==0
                obj.real=0;
                obj.init=1;
            else
                
                %p=closurePrices;
                r=returns(:,2);
                
                if length(r)<2
                    obj.real=0;
                else
                    if r(end)<0 && r(end-1) < 0
                        obj.real=0;
                    elseif r(end)>0 && r(end-1) > 0
                        obj.real=1;
                    end
                end
            end

        end

        
        
        function obj = decisionReal2 (obj,closurePrices)
            
            %NOTE: controlla un certo numero di ultime chiusure e se sono 
            %in una certa percentuale concordi opera altrimenti no
            
            if obj.init ==0
                obj.real=0;
                obj.init=1;
            else
                
                p=closurePrices;
                %bc = altiBassicontatore(p);
                
                cc=-diff(p(1:10));
                [~,~,gt]=find(cc>0);
                [~,~,lt]=find(cc<0);
                if length(gt)>2 || length (lt)>2
                    obj.real = 1;
                else
                    obj.real = 0;
                end
                            
                
            end
        end
        
        
        function obj = decisionReal3 (obj,closurePrices,volumes,vtresh,vlimit)
            
            %NOTE: controlla che le ultime chiusure siano concordi e poi
            %decide cosa fare
            
            if obj.init ==0
                obj.real=0;
                obj.init=1;
            else
                
                v=volumes;
%                 vl=20;
%                 if length(v) < vl
%                     vm=mean(v);
%                 else
%                     vm=mean(v(1:vl));
%                 end
%                 f=1.2;
%                 vlimit=f*vm;
                
                %vtresh=20;
                %vlimit=400;
                
                
                p=closurePrices;
                bc = altiBassicontatore(p);

                
                if bc(1,1) > 1 || v(1,1)> vlimit
                    if v(1,1)< vtresh
                        obj.real = 1;
                    else
                        obj.real = 0;
                    end
                else
                    obj.real = 1;
                end
                                
            end
        end
        
        
        function obj = decisionReal4 (obj,closurePrices)
            
            %NOTE: controlla che le ultime chiusure siano concordi e poi
            %decide cosa fare
            
            if obj.init ==0
                obj.real=0;
                obj.init=1;
            else
                  
                
                p=closurePrices;
                bc = altiBassicontatore(p);

                %condizione sulle chiusure on-line 240min (deve essere 0 1)
                if bc(1,1) > 1 
                    obj.real = 0;
                else
                    obj.real = 1;
                end
                
                
            end
        end
       
        
        
        function obj = decisionReal5 (obj,volumes,vtresh,vlimit)
            
            %NOTE: controlla solo i volumi
            
            if obj.init ==0
                obj.real=0;
                obj.init=1;
            else
                
                v=volumes;
                %                 vl=20;
                %                 if length(v) < vl
                %                     vm=mean(v);
                %                 else
                %                     vm=mean(v(1:vl));
                %                 end
                %                 f=1.2;
                %                 vlimit=f*vm;
                
                %vtresh=20;
                %vlimit=400;
                
                %lavoro sui VOLUMI ALTI
                
                if v(1,1)> vtresh && v(1,1)<vlimit
                    obj.real = 1;
                else
                    obj.real = 0;
                end
                
            end
        end
        
        
        
        %% decision Direction
        
        % funzione per gestire la direzione da intraprendere in entrambi i
        % casi (real=0 o real=1)
        function [params,operationState,counter] = decisionDirection1 (obj,closurePrices,params,operationState,TakeP,StopL)
            
            p=closurePrices;
            
            bc = altiBassicontatore(p);
            
            if bc(1,1) > 1
                obj.direction = sign(bc(1,2));
            else
                obj.direction = -sign(bc(1,2));
            end
            
            %MODIFICATA LA GESTIONE DEL TP E SL !!!!!
            
           
            %scommentare per usare la funzione "cicle" per ciclare su dev
            
            %mult = params.get('mult______');
            currValue = p(end);
            operationState.actualOperation = obj.direction;
            
            params.set('openValue_',currValue);
            params.set('closeValue',-1);
            %params.set('stopLoss__',mult*dev);
            params.set('stopLoss__',StopL);
            params.set('noLoose___',TakeP);
            params.set('maxPercTp_',1);
            params.set('initPercTp',1);
            params.set('real______',obj.real);
            
            counter = 0;
            
        end
        
        function [params,operationState,counter] = decisionDirection2 (obj,closurePrices,params,operationState,TakeP,StopL)
                       
            p=closurePrices;
            %bc = altiBassicontatore(p);
            
            cc=-diff(p(1:10));
            [~,~,gt]=find(cc>0);
            [~,~,lt]=find(cc<0);
            if length(gt)>length(lt)+1 
                obj.direction = 1;
            elseif length (lt)>length(gt)+1
                obj.direction = -1;
            else
                obj.direction = operationState.lastOperation;
            end
            

            %scommentare per usare la funzione "cicle" per ciclare su dev
            
            %mult = params.get('mult______');
            currValue = p(end);
            operationState.actualOperation = obj.direction;
            
            params.set('openValue_',currValue);
            params.set('closeValue',-1);
            %params.set('stopLoss__',mult*dev);
            params.set('stopLoss__',StopL);
            params.set('noLoose___',TakeP);
            params.set('maxPercTp_',1);
            params.set('initPercTp',1);
            params.set('real______',obj.real);
            
            counter = 0;
            
        end
        
        %%
        function [params,operationState,counter] = decisionDirectionTest (obj,closurePrices,params,operationState,cState,TakeP,StopL)
            
            p=closurePrices;

            obj.direction = cState.suggestedDirection;

            currValue = p(end);
            operationState.actualOperation = obj.direction;
            
            params.set('openValue_',currValue);
            params.set('closeValue',-1);
            %params.set('stopLoss__',mult*dev);
            params.set('stopLoss__',StopL);
            params.set('noLoose___',TakeP);
            params.set('maxPercTp_',1);
            params.set('initPercTp',1);
            params.set('real______',obj.real);
            
            counter = 0;
            
        end
        
        
        
        
    end
    
end