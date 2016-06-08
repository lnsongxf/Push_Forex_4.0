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
index = length(vettore)-1;
s = size(matrix);
s(1) = s(1) - 1;
ma=zeros(s);
ma(:,2)=diff(vettore);
[state,P1]=anderson(ma,-1,2);

if operationState.lock
    counter = counter + 1;
    if(counter > 5)
        operationState.lock = 0;
        counter = 0;
    end
end

if (operationState.lock == 0)
    if abs(operationState.actualOperation) > 0
        if(operationState.phase == 0)
            [operationState,~,params] = phaseZeroManager(operationState,values,params);
        elseif(operationState.phase == 1)
            [operationState,~,params] = phaseOneManager(operationState,values,params);
        end
    else
        if state
            if abs(operationState.actualOperation) == 0
                
                earn = 3;
                
                [w,l,dev] = simul(vettore(end-index:end),1);
                %earn = w*dev-l*2*dev;
                %if(dev < 4)
                %    earn = 1;
                %end
                if (earn > 2)

                    ao = 0;
                    counter = 0;
     
                    subplot(2,1,1);
                    plot(vettore);
                    hold on;
                   
                    c = csaps(1:length(vettore),vettore,params.get('coeff_____'),1:length(vettore));
                    plot(c,'r');
                    pause(.1);
                    [crit,b] = getCritPoints(c,vettore);
                    amp = diff(crit);
                    
                    periods = diff(find(b>0));
                    if isempty(periods)
                        periods = length(vettore)-1;
                    end
                    
                    if isempty(amp)
                        amp = vettore(end)-vettore(1);
                    end
                    
                    sl = 2*dev;
                    
                    try
                        actDir = sign(crit(end)-crit(end-1));
                        
                        if(crit(end-1) > min(crit) && crit(end-1) < max(crit) && crit(end-2) > min(crit) && crit(end-2) < max(crit))
                            if(sign(crit(end)-crit(end-1)) == -1*sign(crit(end)-crit(end-2)))
                                dist = abs(amp(end));
                                if(dist < abs(amp(end-1))*2/5)
                                    ao = actDir;
                                elseif (dist > abs(amp(end-1))*4/5)
                                    ao = -actDir;
                                end
                            end
                        else
                            if crit(end-1) == min(crit)
                                ao = -1;
                            elseif crit(end-1) == max(crit)
                                ao = 1;
                            end
                        end
                        dev = abs(amp(end-1))*3/4;
                        sl = 2*dev;
                        if dev < 6
                            ao = 0;
                        end
                    catch Ex
                        ao = 0;
                    end
                    
                    if(dev <= 20)
                        iptp = .9;
                    else
                        iptp = .9;
                    end
                    
                    operationState.actualOperation = ao;
                    params.set('openValue_',currValue);
                    params.set('closeValue',-1);
                    params.set('stopLoss__',sl);
                    params.set('noLoose___',dev);
                    params.set('maxPercTp_',.9);
                    params.set('initPercTp',iptp);
                    params.set('maxDelta__',150);
                    hold off;
                    
                end
            end
        end
    end
end

