function [operationState,values,params] = lifeCicleNew_binary(operationState, values,params)

r = rand(1,1) > .99;
if r
    tic
end
global counter;
global lockCounter;

if(isempty(lockCounter))
    lockCounter = 60;
end

index=length(values.matrixVal)-1;
matrix=values.matrixVal(end-index+1:end,:);
vettore = matrix(:,4);

currValue = vettore(length(vettore));

if operationState.lock
    counter = counter + 1;
    if(counter > 0)
        c = csaps(1:length(vettore),vettore,params.get('coeff_____'),1:length(vettore));
        g = gradient(c);
        if(g(end)*sign(operationState.lastOperation) < 0)
            operationState.lock = 0;
            counter = 0;
        end
    end
end

if (operationState.lock == 0)
    if abs(operationState.actualOperation) > 0
        lockCounter = lockCounter + 1;
        if(operationState.phase == 0)
            
            [operationState,~,params] = phaseZeroManager(operationState,values,params);
            if lockCounter >= 40
                params.set('stopLoss__',max(30,params.get('stopLoss__')/2));
                lockCounter = 0;
            end
        elseif(operationState.phase == 1)
            [operationState,~,params] = phaseOneManager(operationState,values,params);
        end
    else
        
        if abs(operationState.actualOperation) == 0
            c = csaps(1:length(vettore),vettore,params.get('coeff_____'),1:length(vettore));
            g = gradient(c);
            state = isClusterable(abs(g),5,4);
            if (state)
                
                ao = sign(vettore(end)-vettore(end-1));
                counter = 0;
                lockCounter = 0;
                subplot(2,1,1);
                plot(vettore);
                hold on;
                
                pause(.1);
                operationState.actualOperation = ao;
                params.set('openValue_',currValue);
                params.set('closeValue',-1);
                params.set('stopLoss__',120);
                params.set('noLoose___',15);
                params.set('maxPercTp_',.9);
                params.set('initPercTp',.9);
                params.set('maxDelta__',150);
                hold off;
                
            end
        end
    end
end
end

