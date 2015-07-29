classdef Optimization < handle
    
    properties
        optimizResult;
        algorithm;
        startingIndex;
        struct;
        cross;
        time;
    end
    
    methods
        
        function obj = Optimization(hist)
            
            obj.algorithm           = OptimizationAlgorithmFake;
            obj.algorithm.optimize  = 0;
            obj.algorithm.history   = hist;
        end
        
        function obj = buildOptResult(obj,dimension)
            clear obj.optimizResult;
            obj.optimizResult = OptimizationResultContainer(dimension);
            %for i = 1 : dimension
            %   obj.optimizResult.se(i) = OptimizationResult(0, 1);
            %end
        end
        
        function params = optimize(obj,params,index)
            worked = 0;
            cond1 = 0;
            %cond1 = 1;
            %ov = params.get('openValue_');
            %cv = params.get('closeValue');
            %vp = params.get('valueTp___');
            %optT= params.get('optimizedT');
            %optP= params.get('optimizedP');
            %if((sign(vp-ov) == sign(vp-cv)*-1) || (cv == vp) || cv == -1)
            %    cond1 = 0;
            %end
            %if((mod(index,12) == 0 && optT==0) || (cond1 && optP==0))
            if(cond1)
                finalEarning = 0;
                
                if(cond1)
                    params.set('optimizedP',1);
                    params.set('optimizedT',0);
                else
                    params.set('optimizedT',1);
                    params.set('optimizedP',0);
                end
                
                params.optimized = 1;
                
                obj.algorithm.params = params;
                obj.algorithm.deltaIndex = 100;
                obj.algorithm.actOper = SingleOperation;
                obj.algorithm.params.working = 1;
                
                iter = -1;
                
                finished = 0;
                tempValues = zeros(1,length(obj.algorithm.params.map));
                oldValues  = zeros(1,length(obj.algorithm.params.map));
                it = MapIterator(obj.algorithm.params.map);
                k = 1;
                while it.hasNext
                   key = it.next;
                   tempValues(k) =  obj.algorithm.params.get(key);
                   oldValues(k)  =  obj.algorithm.params.get(key);
                   k = k + 1;
                end
                
                while((iter < obj.algorithm.params.get('maxIterOpt') && finished == 0))
                    k = 0;
                    it = MapIterator(obj.algorithm.params.map);
                    it.reset;
                    iter = iter + 1;
                    
                    while(it.hasNext && (finished == 0 || iter == 0))
                        k = k + 1;
                        
                        key = it.next;
                        p = obj.algorithm.params.getVar(key);
                        
                        tempValue = tempValues(k);
                        if(p.optimize)
                            worked = 1;
                            range = p.range;
                            memories = zeros(1,length(range));
                            for i = 1 : length(range)
                                obj.algorithm.actOper    = SingleOperation;
                                obj.algorithm.operations = Operations;
                                obj.algorithm.operStates = OperationState;
                                obj.algorithm.params.set(key,range(i));
                                obj.algorithm.params.getVar(key).setOldValue(range(i));
                                
                                obj.algorithm.startingIndex = index - 6;
                                obj.algorithm.lastIndex    = index;
                                obj.algorithm.optimize    = 0;
                                obj.algorithm.spin;
                                obj.algorithm.operations.totalEarningCalculation;
                                memories(i) = obj.algorithm.operations.totalEarning;
                                display(strcat('Guadagno singola ottimizzazione: ',mat2str(memories(i))));
                                display(strcat(key,mat2str(range(i))));
                            end
                            
                            memories = obj.optimizResult.get(k).sumOptResult(memories');
                            l = length(range);
                            c = csaps(1:l,memories,.7,1:(l-1)/100:l);
                            g = gradient(c);
                            
                            newValue = 0;
                            
                            maxWin = c(1);
                            changed = 0;
                            for j = 2 : length(g)-1;
                                if(g(j)>= 0 && g(j+1)<=0)
                                    if(maxWin < c(j+1))
                                        maxWin = c(j+1);
                                        newValue = range(1) + ...
                                            (j+1)*(range(l)-range(1))/100;
                                        changed = 1;
                                    end
                                end
                            end
                            
                            finalEarning = maxWin;
                            if(changed == 0)
                                if(memories(1) < memories(length(memories)))
                                    position = length(range);
                                    newValue = range(position);
                                else
                                    %if(memories(1) < 0)
                                    %    newValue = tempValues(k);
                                    %else
                                        newValue = range(1);
                                    %end
                                end
                            end
                            
                            
                            %obj.optimizResult(k).boundaryConditions;
                            %if(obj.optimizResult(k).finished == 1)
                            %    finished = 0;   
                            %end
                            
                            delta = abs(tempValue - newValue);
                            if(delta <= p.delta)
                                finished = 1;
                            else
                                finished = 0;
                            end
                            
                            tempValues(k) = newValue;
                            obj.algorithm.params.set(key,newValue);
                        end
                    end 
                end
                it = MapIterator(obj.algorithm.params.map);
                k = 1;
                while it.hasNext
                   key = it.next;
                   obj.algorithm.params.getVar(  key).setOldValue(tempValues(k));
                   obj.algorithm.params.set(key, oldValues(k));
                   display(strcat(key,'=',mat2str(tempValues(k))));
                   k = k + 1;
                end
                
                for k = 1 : obj.optimizResult.numberOfValues
                    obj.optimizResult.get(k).saveResult;
                end
                %%%%%%
                finalEarning = max(memories);
                %%%%%%
                if worked
                    obj.algorithm.params.working = finalEarning > 0;
                end
                if obj.algorithm.params.working == 0
                    params.set('optimizedT',0);
                end
                clear it;
                
            else
                params.optimized = 0;
            end
        end    
    end
end


