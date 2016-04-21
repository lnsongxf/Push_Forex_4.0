classdef bktFast_hurst < handle
    
    %%%%%%%%%%%%%%%%
    %%% use it like this: (put smoothHurstDiff to 0 if does not exists)
    % fast = bktFast;
    % fast = fast.optimize('parameters_file.txt',smoothHurstDiff)
    %
    %%% or to simply check that an algo it's working:
    %%% and to generate the Hurst vector the first time to speedup the
    %%% optimization processes
    %
    % test = bktFast;
    % [test,smoothHustDiff] = test.tryme('parameters_file.txt',smoothHurstDiff)
    %
    %%% or to compare results: (devi aver gia' calcolato lo smoothHurstDiff!!)
    %
    % test = bktFast;
    % test.plotme('parameters_file.txt', smoothHurstDiff)
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
        
        function [obj] = optimize(obj,parameters,smoothHurstDiff)
            
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
            
            if ( exist('reverse_optimization','var') && reverse_optimization == 1 )
                
                % split historical and perform optimization on the MOST RECENT HISTORICAL DATA!!!!
                % default for reverse_optimization: 50% Training, 50% paper trading)
                rTraining = floor(r*0.5);
                rnTraining = floor(rTraining/newTimeScale);
                
                hisDataTraining = hisData(rTraining+1:end,:);
                hisDataPaperTrad = hisData(1:rTraining,:);
                newHisDataTraining = newHisData(rnTraining+1:end,:);
                newHisDataPaperTrad = newHisData(1:rnTraining,:);
                
            else % standard way!
                
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
                
            end
            
            
            %% Perform optimization using training set
            
            matrixsize = max([ N M ]);
            obj.R_over_maxDD = nan(matrixsize);
            
            tic
            
            P = newHisData(:,4);
            
            % iterative (slow!!) stationarity test (calcolates Hurst exponent once for all)
            % la prima volta che fai girar il tryme ti genera la variabile
            % smoothHurstDiff che puoi usare anche x l'ottimizzazione
            if (smoothHurstDiff == 0)
                Hurst = nan(size(P));
                smoothHurstDiff = nan(size(P));
                st=stationarity;
                
                display('I am generating the Hurst variable, will take some time...');
                display(length(P));
                
                for j=100:length(P)
                    
                    st.stationarityTests(P(j-99:j),newTimeScale,0);
                    Hurst(j) = st.HurstExponent;
                    [~,HurstDiff] = smoothDiff(Hurst(j-99:j),0.5);
                    smoothHurstDiff(j) = mean(HurstDiff(end-5:end-1));
                    
                end
                
            end
            
            for n = N
                
                display(['n =', num2str(n)]);
                
                for m = M
                    
                    if( N_greater_than_M && n<=m )
                        continue
                    end
                    
                    bktfast = feval(algo);
                    %                       spin(            Pmin,           matrixNewTimeScale, actTimeScale, newTimeScale, N, M, transCost, pips_TP, pips_SL, stdev_TP,stdev_SL, plot, Hurst_vector)
                    bktfast = bktfast.spin(hisDataTraining(:,4), newHisDataTraining, actTimeScale, newTimeScale, n, m, transCost, pips_TP, pips_SL, stdev_TP, stdev_SL, 0, smoothHurstDiff(1:rnTraining,:));
                    
                    % if there are enough operations then save the stats
                    if bktfast.indexClose>20
                        
                        p = Performance_06;
                        performance = p.calcSinglePerformance(nameAlgo,'bktWeb',histName,Cross,newTimeScale,transCost,10000,10,bktfast.outputbkt,0);
                        
                        obj.R_over_maxDD(n,m) = performance.pipsEarned / abs(performance.maxDD_pips);
                        
                    end
                    
                end
                
                % display partial results of optimization
                [current_best,ind_best] = max(obj.R_over_maxDD(n,:));
                
                temp_Training = feval(algo);
                temp_Training = temp_Training.spin(hisDataTraining(:,4), newHisDataTraining, actTimeScale, newTimeScale, n, ind_best, transCost, pips_TP, pips_SL, stdev_TP, stdev_SL, 0, smoothHurstDiff(1:rnTraining,:));
                
                if temp_Training.indexClose>20
                    performance_temp_Training = p.calcSinglePerformance(nameAlgo,'bktWeb',histName,Cross,newTimeScale,transCost,10000,10,temp_Training.outputbkt,0);
                    
                    display(['Train: best R/maxDD=' , num2str(current_best),'.  N =', num2str(n),' M =', num2str(ind_best) ]);
                    display(['num operations =', num2str(temp_Training.indexClose) ,', pips earned =', num2str(performance_temp_Training.pipsEarned)]);
                    
                    % try paper trading on partial result and display some numbers
                    
                    temp_paperTrad = feval(algo);
                    temp_paperTrad = temp_paperTrad.spin(hisDataPaperTrad(:,4), newHisDataPaperTrad, actTimeScale, newTimeScale, n, ind_best, transCost, pips_TP, pips_SL, stdev_TP, stdev_SL, 0, smoothHurstDiff(rnTraining+1:end,:));
                    performance_temp = p.calcSinglePerformance(nameAlgo,'bktWeb',histName,Cross,newTimeScale,transCost,10000,10,temp_paperTrad.outputbkt,0);
                    
                    risultato_temp = performance_temp.pipsEarned / abs(performance_temp.maxDD_pips) ;
                    display(['Papertrad: R/maxDD =', num2str(risultato_temp)]);
                    display(['num operations =', num2str(temp_paperTrad.indexClose) ,', pips earned =', num2str(performance_temp.pipsEarned) ]);
                    
                    %plot if it is good:
                    if risultato_temp > 1.0 && WhatToPlot > 1
                        
                        
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
                
                
                
            end
            
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
            obj.bktfastTraining = obj.bktfastTraining.spin(hisDataTraining(:,4), newHisDataTraining, actTimeScale, newTimeScale, bestN, bestM, transCost, pips_TP, pips_SL, stdev_TP, stdev_SL, 0, smoothHurstDiff(1:rnTraining,:));
            
            p = Performance_06;
            obj.performanceTraining = p.calcSinglePerformance(nameAlgo,'bktWeb',histName,Cross,newTimeScale,transCost,10000,10,obj.bktfastTraining.outputbkt,0);
            
            risultato = obj.performanceTraining.pipsEarned / abs(obj.performanceTraining.maxDD_pips);
            
            if WhatToPlot > 0
                
                figure
                plot(cumsum(obj.bktfastTraining.outputbkt(:,4) - transCost))
                title(['Training Best Result, Final R over maxDD = ',num2str( risultato) ])
                
            end
            
            
            %% perform paper trading
            
            obj.bktfastPaperTrading = feval(algo);
            obj.bktfastPaperTrading = obj.bktfastPaperTrading.spin(hisDataPaperTrad(:,4), newHisDataPaperTrad, actTimeScale, newTimeScale, bestN, bestM, transCost, pips_TP, pips_SL, stdev_TP, stdev_SL, smoothHurstDiff(rnTraining+1:end,:));
            
            obj.performancePaperTrad = p.calcSinglePerformance(nameAlgo,'bktWeb',histName,Cross,newTimeScale,transCost,10000,10,obj.bktfastPaperTrading.outputbkt,0);
            risultato = obj.performancePaperTrad.pipsEarned / abs(obj.performancePaperTrad.maxDD_pips);
            
            if WhatToPlot > 0
                
                figure
                plot(cumsum(obj.bktfastPaperTrading.outputbkt(:,4) - transCost))
                title(['Paper Trading Result, Final R over maxDD = ',num2str( risultato) ])
                
            end
            
            
            
        end % end function optimize
        
        
        
        %%%%%%%%%
        
        function [obj, smoothHurstDiff] = tryme(obj,parameters,smoothHurstDiff)
            
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
            
            
            P = newHisData(:,4);
            
            % iterative (slow!!) stationarity test (calcolates Hurst exponent once for all)
            % la prima volta che fai girar il tryme ti genera la variabile
            % smoothHurstDiff che puoi usare anche x l'ottimizzazione
            if (smoothHurstDiff == 0)
                Hurst = nan(size(P));
                smoothHurstDiff = nan(size(P));
                st=stationarity;
                
                display('I am generating the Hurst variable, will take some time...');
                display(length(P));
                
                for j=100:length(P)
                    
                    st.stationarityTests(P(j-99:j),newTimeScale,0);
                    Hurst(j) = st.HurstExponent;
                    [~,HurstDiff] = smoothDiff(Hurst(j-99:j),0.5);
                    smoothHurstDiff(j) = mean(HurstDiff(end-5:end-1));
                    
                end
                
            end
            
            %% perform try
            
            obj.bktfastTry = feval(algo);
            obj.bktfastTry = obj.bktfastTry.spin(hisData(:,4), newHisData, actTimeScale, newTimeScale, N, M, transCost, pips_TP, pips_SL, stdev_TP, stdev_SL, 0, smoothHurstDiff);
            
            p = Performance_06;
            obj.performanceTry = p.calcSinglePerformance(nameAlgo,'bktWeb',histName,Cross,newTimeScale,transCost,10000,10,obj.bktfastTry.outputbkt,1);
            risultato = obj.performanceTry.pipsEarned / abs(obj.performanceTry.maxDD_pips);
            
            if WhatToPlot > 0
                
                figure
                plot(cumsum(obj.bktfastTry.outputbkt(:,4) - transCost))
                title(['Result, Final R over maxDD = ',num2str( risultato) ])
                
            end
            
            
        end % end of function tryme
        
        function [obj] = plotme(obj,parameters, smoothHurstDiff )
            
            % DESCRIPTION:
            % -------------------------------------------------------------
            % Performs simple run of the specified algorithm on given historical data
            % and compare result overplotting them on a single plot
            %
            %
            % How to use it:
            %
            % test = bktFast;
            % test = test.plotme('parameters_file.txt')
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
            
            figure
            hold on
            
            Legend = cell( size(N,2)*size(M,2) , 1);
            LegNum=1;
            
            for n = N
                
                display(['n =', num2str(n)]);
                
                
                for m = M
                    
                    if( N_greater_than_M && n<=m )
                        continue
                    end
                    
                    obj.bktfastTry = feval(algo);
                    obj.bktfastTry = obj.bktfastTry.spin(hisData(:,4), newHisData, actTimeScale, newTimeScale, n, m, transCost, pips_TP, pips_SL, stdev_TP, stdev_SL, 0, smoothHurstDiff);
                    
                    %                     subpl(LegNum) = subplot( size(N,2), size(M,2), LegNum );
                    plot(cumsum(obj.bktfastTry.outputbkt(:,4) - transCost),'color',rand(1,3))
                    Legend{LegNum}=strcat( num2str(n),'-',num2str(m) );
                    LegNum= LegNum+1;
                    
                end
                
            end
            
            %             linkaxes(subpl,'y')
            legend(Legend)
            title('Cumulative Results of various trials')
            
        end % end of function plotme
        
        
    end % end of methods
    
end % end of classdef