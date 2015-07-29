function [operationState,values,params] = lifeCicleNew_binary(operationState, values,params)

r = rand(1,1) > .99;
if r
    tic
end
global counter;
global operType;
global ff;
global xx;
global sommaVincite;
global lVincite;
global mult;
global lock;

if(isempty(sommaVincite))
    sommaVincite = 0;
    lVincite = 0;
end
if(isempty(mult))
    mult = 0;
end
state = 1;
vettore = [];
if state && operationState.lock
    if sign(params.get('openValue_')-params.get('closeValue')) == operationState.lastOperation
        mult = 0;
    end
    vettore = values.getClosureVect;
    counter = counter + 1;
    if(counter > 0)
        operationState.lock = 0;
        counter = 0;
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
        
        start = 0;
        if start
            
        else
            if abs(operationState.actualOperation) == 0
                if isempty(vettore)
                    vettore = values.getClosureVect;
                end
                currValue = vettore(length(vettore));
                
                %state = fourierInBinary(vettore);
                subplot(2,1,1);
                if state
                    v = vettore(1:end);
                    [~,x,f] = descenExtrPointsAlgo(v',3);
                    
                    hold off
                    xx = x{length(x)};
                    ff = f{length(x)};
                    dev=limitOfBinary(ff,v(xx));
                    display(strcat('media w: ',num2str(sommaVincite/lVincite)));
                    earn = 3;
                    display(strcat('earn   : ',num2str(earn)));
                    
  
                    if (earn > 2 && dev > 5)
                        display('CRISTIANO');
                        hold off;
                        subplot(2,1,1);
                        plot(v(xx));
                        hold on;
                        plot(1:1:length(xx),ff+dev,'r');
                        plot(1:1:length(xx),ff-dev,'r');
                        pause(1);
                        hold off;
                        operType = 0;
                        counter = 0;
                        
                        iptp = .9;
                        if (abs(currValue-ff(1)) > dev*1.5)
                            mult = mult + 1;
                            ao = -sign(ff(length(ff))-currValue);
                            tp = .5;
                            sl = min(abs(currValue-ff(1)) / dev / mult,2);
                            iptp = .9;
                            if (lock || mult > 2)
                                if mult > 2
                                    pf = polyfit(1:(length(vettore)-xx(1)+1),vettore(xx(1):end),1);
                                    pv = polyval(pf,1:(length(vettore)-xx(1)));
                                    d = currValue - pv(end);
                                    hold on
                                    plot(pv);
                                    pause(.1);
                                    hold off
                                    if(sign(d) == ao)
                                       ao = 0; 
                                    end
                                else
                                    ao = 0;
                                end
                            end
                        elseif (dev < 26)
                            lock = 0;
                            ao = sign(ff(length(ff))-currValue);
                            tp = .5;
                            sl = 1.2*2;
                            
                        elseif (dev > 26)
                            ao = -sign(ff(length(ff))-currValue);
                            pf = polyfit(1:(length(vettore)-xx(1)+1),vettore(xx(1):end),1);
                            pv = polyval(pf,1:(length(vettore)-xx(1)));
                            d = currValue - pv(end);
                            hold on
                            plot(pv);
                            pause(.1);
                            hold off
                            if(sign(d) == ao)
                                ao = 0;
                                sl = 1;
                                tp = 1;
                                lock = 0;
                            else
                                lock = 0;
                                tp = .5;
                                sl = .75;
                            end
                        else
                            ao = 0;
                            sl = 1;
                            tp = 1;
                            lock = 0;
                        end
                        
                       operationState.actualOperation = ao;
                        params.set('openValue_',currValue);
                        params.set('closeValue',-1);
                        params.set('stopLoss__',sl*dev);
                        params.set('noLoose___',tp*dev);
                        params.set('maxPercTp_',.9);
                        params.set('initPercTp',iptp);
                    end
                else
                    %display('trend non gaussiano');
                end
            end
        end
    end
end

if r
    toc
end
end

