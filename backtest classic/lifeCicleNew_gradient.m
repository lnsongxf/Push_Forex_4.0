function [operationState,values,params] = lifeCicleNew_gradient(operationState, values,params)

    global persCount;
    if isempty(persCount)
        persCount = 0;
    end
    persCount = persCount + 1;
    vettore = values.getClosureVect;
    currValue = vettore(length(vettore));
    
    ma = movavg(vettore,5,20);
    g  = gradient(ma);
    g2 = gradient(g);
    %v = vettoreOscillazioni(vettore,g);
    
    if operationState.lock
        if(changeDerivative(g,operationState.lastOperation))
            operationState.lock = 0;
        end
    end
    
    if (operationState.lock == 0 && abs(operationState.actualOperation) == 0)
        
        if ((mod(persCount,60) == 1 || mod(persCount,60) == 2) && g(length(g))*g2(length(g2)) > 0)
            
            %s  = std(v);
            subplot(2,1,1);
            plot(vettore(length(vettore)-20:length(vettore)));
            pause(1);
            bc = altiBassi(vettore);
            found = 1;
            while found
                try
                    [~,kkc] = kmeans(abs(bc(:,2)),3);
                    found = 0;
                catch e
                    display('riprova');
                end
            end
            kkc = sort(kkc);
            stopLoss = kkc(2);
            operationState.actualOperation = sign(g(length(g)));
            params.set('openValue_',currValue);
            params.set('closeValue',-1);
            params.set('stopLoss__',stopLoss);
            params.set('noLoose___',kkc(1));
            params.set('maxPercTp_',.75);
            params.set('initPercTp',.1);
        end
       
    elseif abs(operationState.actualOperation) > 0
        if(mod(persCount,60) == 1 && changeDerivative(g,operationState.actualOperation))
            operationState.lastOperation = operationState.actualOperation;
            operationState.actualOperation = 0;
            params.set('closeValue',currValue);
        elseif(operationState.phase == 0)
            [operationState, values, params] = phaseZeroManager(operationState,values,params);
        elseif(operationState.phase == 1)
            [operationState, values, params] = phaseOneManager(operationState,values,params);
        end
    end


end

