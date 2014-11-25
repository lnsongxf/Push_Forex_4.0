function [operationState,values,params] = lifeCicleNew_binary(operationState, values,params)

r = rand(1,1) > .99;
if r
    tic
end
global counter;
global operType;

vettore = values.getClosureVect;
currValue = vettore(length(vettore));
%[state,lowBound, upBound,stopLoss,noLoose,index] = inBinary(vettore);
index=24;
matrix=values.matrixVal;
s = size(matrix);
m=zeros(s(1)-1,s(2));
m(:,2)=diff(matrix(:,4));
[state,P]=anderson(m(end-index+1:end,:),0.1);
display(P);

if state && operationState.lock
    counter = counter + 1;
    if(counter > 60)
        bc = altiBassicontatore(vettore);
        if bc(end,1) == 0
            operationState.lock = 0;
            counter = 0;
        end
    end
end

if (operationState.lock == 0)
    if abs(operationState.actualOperation) > 0
        if(operationState.phase == 0)
            [operationState, values, params] = phaseZeroManager(operationState,values,params);
        elseif(operationState.phase == 1)
            [operationState, values, params] = phaseOneManager(operationState,values,params);
        end
        
    else
        if state == 1
            
        else
            if abs(operationState.actualOperation) == 0
                
                bc = altiBassicontatore(vettore);
                
                %[w,l,dev, mu] = simul(vettore(end-index+1:end),1);
                %earn = w*dev-l*2*dev;
                earn = 8;
                if (earn > 7)
                    display('CRISTIANO');
                    subplot(2,1,1);
                    plot(vettore(end-index+1:end));
                    pause(1);
                    operType = 0;
                    counter = 0;
                    
                    k = 0;
                    ao = 0;
                    
                    if bc(end-1,1) > 0
                        ao = sign(bc(end-1,2));
                    else
                        while ao == 0
                            ao = -sign(bc(end-k,2));
                            k = k+1;
                        end
                    end
                    %ao = ((randi(2)-1)*2)-1;
                    ao = sign(bc(end-1,2));
                    dev = 12;
                    operationState.actualOperation = ao;
                    params.set('openValue_',currValue);
                    params.set('closeValue',-1);
                    params.set('maxDelta__',200);
                    params.set('stopLoss__',abs(bc(end-1,2)));
                    params.set('noLoose___',2*dev);
                    params.set('maxPercTp_',.9);
                    params.set('initPercTp',.1);
                    params.set('deltaBinar',2*dev);
                end
                
            end
        end
    end
end
if r
    toc
end
end

