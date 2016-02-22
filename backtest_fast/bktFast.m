classdef bktFast < handle
    
    %%%%%%%%%%%%%%%%
    %%% use it like this:
    % fast = bktFast;
    % fast = fast.optimize('parameters_file.txt')
    %
    %%% or to simply check that an algo it's working:
    %
    % test = bktFast;
    % test = test.tryme('parameters_file.txt')
    %
    %%%%%%%%%%%%%%%%
    
    
    properties
        R_over_maxDD
        bktfastTraining
        performanceTraining
        bktfastPaperTrading
        performancePaperTrad
        bktfastTry
        performanceTry
        
    end
    
    methods
        
        %%%%%%%%%
        
        function [obj] = optimize(obj,parameters)
            
            % DESCRIPTION:
            % -------------------------------------------------------------
            % Performs the optimization of the specified algorithm on given historical data
            %
            % INPUT parameters:
            % -------------------------------------------------------------
            % nameAlgo:                 string containing the name of the algo (your MATLAB function)
            % N:                        first optimization (use array!!!) -> lag,slowly varying
            % M:                        second optimization (use array or put = 1 !!!) -> lead,highly varying
            % N_greater_than_M:         if = 1 then skip loops where n<=m (required in some algo with smoothing)
            % Cross:                    e.g. 'EURUSD'
            % histName:                 filename containing hist prices, e.g. : 'nome_storico.csv'
            % actTimeScale:             timescale of the hist data, in minutes
            % newTimeScale:             new timescale to work with (rescale)
            % transCost:                spread in pips
            % pips_TP:                  max TP
            % pips_SL:                  max allowed SL
            % stdev_TP:                 stdev(volatility) for calculating TP
            % stdev_SL:                 stdev(volatility) for calculating SL
            % WhatToPlot:               what do you want to plot:
            %                              0: nothing
            %                              1: returns of optimized algo(training and papertrading)
            %                              2: + sweepPlot of training
            %                              3: + performance
            % -------------------------------------------------------------
            
            
            %% Import parameters:
            
            fid=fopen(parameters);
            C = textscan(fid, '%s', 'Delimiter', '', 'CommentStyle', '%');
            fclose(fid);
            cellfun(@eval, C{1});
            
            
            algo = str2func(nameAlgo);
            
            
            %% Load, check, and split historical
            
            [hisData, newHisData] = load_historical(histName, actTimeScale, newTimeScale);
            
            [r,~] = size(hisData);
            %[rn,~] = size(newHisData);
            
            % split historical into trainging set for optimization and paper trading
            % default: 75% Training, 25% paper trading)
            rTraining = floor(r*0.75);
            rnTraining = floor(rTraining/newTimeScale);
            
            % use this to skip some of the very old hist data:
%             skipMe = floor(r*0.20);
%             skipMeNewTime = floor(skipMe/newTimeScale);
%             hisDataTraining = hisData(skipMe:rTraining,:);
%             newHisDataTraining = newHisData(skipMeNewTime:rnTraining,:);
            
            hisDataTraining = hisData(1:rTraining,:);
            hisDataPaperTrad = hisData(rTraining+1:end,:);
            newHisDataTraining = newHisData(1:rnTraining,:);
            newHisDataPaperTrad = newHisData(rnTraining+1:end,:);
            
            
            %% Perform optimization using training set
            
            matrixsize = max([ N M ]);
            obj.R_over_maxDD = nan(matrixsize);
            
            tic
            
            for n = N
                
                display(['n =', num2str(n)]);
                
                
                for m = M
                    
                    if( N_greater_than_M && n<=m )
                        continue
                    end
                    
                    bktfast = feval(algo);
                    %                       spin(            Pmin,           matrixNewTimeScale, actTimeScale, newTimeScale, N, M, transCost, pips_TP, pips_SL, stdev_TP,stdev_SL, plot)
                    bktfast = bktfast.spin(hisDataTraining(:,4), newHisDataTraining, actTimeScale, newTimeScale, n, m, transCost, pips_TP, pips_SL, stdev_TP, stdev_SL, 0);
                    
                    % if there are enough operations then save the stats
                    if bktfast.indexClose>20
                        
                        p = Performance_05;
                        performance = p.calcSinglePerformance(nameAlgo,'bktWeb',Cross,newTimeScale,transCost,10000,10,bktfast.outputbkt,0);
                        
                        obj.R_over_maxDD(n,m) = performance.pipsEarned / abs(performance.maxDD);
                        
                    end
                    
                end
                
                % display partial results of optimization
                [current_best,ind_best] = max(obj.R_over_maxDD(n,:));
                display(['best R/maxDD=' , num2str(current_best),'.  N =', num2str(n),' M =', num2str(ind_best) ]);
                display(['pips earned =', num2str(performance.pipsEarned),', num operations =', num2str(bktfast.indexClose) ]);
                
                % try paper trading on partial result and display some numbers
                
                temp_paperTrad = feval(algo);
                temp_paperTrad = temp_paperTrad.spin(hisDataPaperTrad(:,4), newHisDataPaperTrad, actTimeScale, newTimeScale, n, ind_best, transCost, pips_TP, pips_SL, stdev_TP, stdev_SL, 0);
                performance_temp = p.calcSinglePerformance(nameAlgo,'bktWeb',Cross,newTimeScale,transCost,10000,10,temp_paperTrad.outputbkt,0);
                
                risultato_temp = performance_temp.pipsEarned / abs(performance_temp.maxDD) ;
                display(['papertrad R/maxDD =', num2str(risultato_temp), ', pips earned =', num2str(performance_temp.pipsEarned) ]);
                
                %plot if it is good:
                if risultato_temp > 1.0 && WhatToPlot > 1
                    
                    temp_Training = feval(algo);
                    temp_Training = temp_Training.spin(hisDataTraining(:,4), newHisDataTraining, actTimeScale, newTimeScale, n, ind_best, transCost, pips_TP, pips_SL, stdev_TP, stdev_SL, 0);
                    
                    figure
                    subplot(1,2,1);
                    plot(cumsum(temp_Training.outputbkt(:,4) - transCost))
                    title(['Temp Training Result,', 'N =', num2str(n),' M =', num2str(ind_best) ,'. R over maxDD = ',num2str( current_best) ])
                    hold on
                    subplot(1,2,2);
                    plot(cumsum(temp_paperTrad.outputbkt(:,4) - transCost))
                    title(['Temp Paper Trading Result,', 'N =', num2str(n),' M =', num2str(ind_best) ,'. R over maxDD = ',num2str( risultato_temp) ])
                    
                end
                
            end
            
            hold off
            
            toc
            
            if WhatToPlot > 1
                
                temp=obj.R_over_maxDD;
                temp(isnan( temp) )=0;
                sweepPlot_BKT_Fast(temp)
                
            end
            
            %% display results of training
            
            [~, bestInd] = max(obj.R_over_maxDD(:)); % (Linear) location of max value
            [bestN, bestM] = ind2sub(matrixsize, bestInd); % Lead and lag at best value
            
            display(['bestN =', num2str(bestN),' bestM =', num2str(bestM)]);
            
            obj.bktfastTraining = feval(algo);
            obj.bktfastTraining = obj.bktfastTraining.spin(hisDataTraining(:,4), newHisDataTraining, actTimeScale, newTimeScale, bestN, bestM, transCost, pips_TP, pips_SL, stdev_TP, stdev_SL, 0);
            
            p = Performance_05;
            obj.performanceTraining = p.calcSinglePerformance(nameAlgo,'bktWeb',Cross,newTimeScale,transCost,10000,10,obj.bktfastTraining.outputbkt,0);
            
            risultato = obj.performanceTraining.pipsEarned / abs(obj.performanceTraining.maxDD);
            
            if WhatToPlot > 0
                
                figure
                plot(cumsum(obj.bktfastTraining.outputbkt(:,4) - transCost))
                title(['Training Best Result, Final R over maxDD = ',num2str( risultato) ])
                
            end
            
            
            %% perform paper trading
            
            obj.bktfastPaperTrading = feval(algo);
            obj.bktfastPaperTrading = obj.bktfastPaperTrading.spin(hisDataPaperTrad(:,4), newHisDataPaperTrad, actTimeScale, newTimeScale, bestN, bestM, transCost, pips_TP, pips_SL, stdev_TP, stdev_SL, 0);
            
            obj.performancePaperTrad = p.calcSinglePerformance(nameAlgo,'bktWeb',Cross,newTimeScale,transCost,10000,10,obj.bktfastPaperTrading.outputbkt,0);
            risultato = obj.performancePaperTrad.pipsEarned / abs(obj.performancePaperTrad.maxDD);
            
            if WhatToPlot > 0
                
                figure
                plot(cumsum(obj.bktfastPaperTrading.outputbkt(:,4) - transCost))
                title(['Paper Trading Result, Final R over maxDD = ',num2str( risultato) ])
                
            end
            
            
            
        end % end function optimize
        
        
        
        %%%%%%%%%
        
        function [obj] = tryme(obj,parameters)
            
            % DESCRIPTION:
            % -------------------------------------------------------------
            % Performs simple run of the specified algorithm on given historical data
            %
            %
            % How to use it:
            %
            % test = bktFast;
            % test = test.tryme('parameters_file.txt')
            %
            % -------------------------------------------------------------
            
            
            %% Import parameters:
            
            fid=fopen(parameters);
            C = textscan(fid, '%s', 'Delimiter', '', 'CommentStyle', '%');
            fclose(fid);
            cellfun(@eval, C{1});
            
            
            algo = str2func(nameAlgo);
            
            
            %% Load and check historical
            
            [hisData, newHisData] = load_historical(histName, actTimeScale, newTimeScale);
            
            % check that M or N are no array
            if (size(M,2)>1 || size(N,2)>1 )
                
                M=M(end);
                N=N(end);
                
            end
            
            
            %% perform try
            
            obj.bktfastTry = feval(algo);
            obj.bktfastTry = obj.bktfastTry.spin(hisData(:,4), newHisData, actTimeScale, newTimeScale, N, M, transCost, pips_TP, pips_SL, stdev_TP, stdev_SL, 0);
            
            p = Performance_05;
            obj.performanceTry = p.calcSinglePerformance(nameAlgo,'bktWeb',Cross,newTimeScale,transCost,10000,10,obj.bktfastTry.outputbkt,1);
            risultato = obj.performanceTry.pipsEarned / abs(obj.performanceTry.maxDD);
            
            if WhatToPlot > 0
                
                figure
                plot(cumsum(obj.bktfastTry.outputbkt(:,4) - transCost))
                title(['Result, Final R over maxDD = ',num2str( risultato) ])
                
                % it is not possible to use this as long as there is
                % hurst etc to calculate...
                %                 pD = PerformanceDistribution_04;
                %                 obj.performanceDistribution = pD.calcPerformanceDistr(nameAlgo,'bktWeb',Cross,N,newTimeScale,transCost,obj.bktfastTry.outputbkt,0,hisData,newHisData,15,10,10,4);
                %
                %
            end
            
            
        end % end of function tryme
        
        
    end % end of methods
    
end % end of classdef