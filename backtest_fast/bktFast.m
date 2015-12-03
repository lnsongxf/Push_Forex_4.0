classdef bktFast < handle
    
    properties
        R_over_maxDD
        bktfastTraining
        performanceTraining
        bktfastPaperTrading
        performancePaperTrad
        
    end
    
    methods
        
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
            
            hisDataRaw=load(histName);
            
            % remove lines with no data (holes)
            hisData = hisDataRaw( (hisDataRaw(:,1) ~=0), : );
            
            [r,c] = size(hisData);
            
            % include fake dates if not present in the histfile
            if c == 5
                
                hisData(1,6) = datenum('01/01/2015 00:00', 'mm/dd/yyyy HH:MM');
                
                for j = 2:r;
                    hisData(j,6) = hisData(1,6) + ( (actTimeScale/1440)*(j-1) );
                end
                
            end
            
            % split historical into trainging set for optimization and paper trading
            % default: 75% Training, 25% paper trading)
            rTraining = floor(r*0.75);
            hisDataTraining = hisData(1:rTraining,:);
            hisDataPaperTrad = hisData(rTraining+1:end,:);
            
            % rescale data if requested
            if newTimeScale > 1
                
                expert = TimeSeriesExpert_11;
                
%                 expert.rescaleData(hisData,actTimeScale,newTimeScale);
%
%                 newHisData(:,1) = expert.openVrescaled;
%                 newHisData(:,2) = expert.maxVrescaled;
%                 newHisData(:,3) = expert.minVrescaled;
%                 newHisData(:,4) = expert.closeVrescaled;
%                 newHisData(:,5) = expert.volrescaled;
%                 newHisData(:,6) = expert.openDrescaled;
                
                expert.rescaleData(hisDataTraining,actTimeScale,newTimeScale);
                
                newHisDataTraining(:,1) = expert.openVrescaled;
                newHisDataTraining(:,2) = expert.maxVrescaled;
                newHisDataTraining(:,3) = expert.minVrescaled;
                newHisDataTraining(:,4) = expert.closeVrescaled;
                newHisDataTraining(:,5) = expert.volrescaled;
                newHisDataTraining(:,6) = expert.openDrescaled;
                
                expert.rescaleData(hisDataPaperTrad,actTimeScale,newTimeScale);
                
                newHisDataPaperTrad(:,1) = expert.openVrescaled;
                newHisDataPaperTrad(:,2) = expert.maxVrescaled;
                newHisDataPaperTrad(:,3) = expert.minVrescaled;
                newHisDataPaperTrad(:,4) = expert.closeVrescaled;
                newHisDataPaperTrad(:,5) = expert.volrescaled;
                newHisDataPaperTrad(:,6) = expert.openDrescaled;
                
            end
            
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
                        %                 spin(Pmin,matrixNewTimeScale, actTimeScale,newTimeScale, N, M, transCost, pips_TP, pips_SL, stdev_TP,stdev_SL, plot)
                        bktfast = bktfast.spin(hisDataTraining(:,4), newHisDataTraining, actTimeScale, newTimeScale, n, m, transCost, pips_TP, pips_SL, stdev_TP, stdev_SL, 0);
                        
                        p = Performance_05;
                        performance = p.calcSinglePerformance(nameAlgo,'bktWeb',Cross,newTimeScale,transCost,10000,10,bktfast.outputbkt,0);
                        
                        obj.R_over_maxDD(n,m) = performance.pipsEarned / abs(performance.maxDD);
                        
                end
                
            end
            
            toc
            
            if WhatToPlot > 1
                sweepPlot_BKT_Fast(obj.R_over_maxDD)
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
                plot(cumsum(obj.bktfastTraining.outputbkt(:,4)))
                title(['Training Best Result, Final R over maxDD = ',num2str( risultato) ])
            end
            
            
            %% perform paper trading
            obj.bktfastPaperTrading = feval(algo);
            obj.bktfastPaperTrading = obj.bktfastPaperTrading.spin(hisDataPaperTrad(:,4), newHisDataPaperTrad, actTimeScale, newTimeScale, bestN, bestM, transCost, pips_TP, pips_SL, stdev_TP, stdev_SL, 0);
            
            p = Performance_05;
            obj.performancePaperTrad = p.calcSinglePerformance(nameAlgo,'bktWeb',Cross,newTimeScale,transCost,10000,10,obj.bktfastPaperTrading.outputbkt,0);
            risultato = obj.performancePaperTrad.pipsEarned / abs(obj.performancePaperTrad.maxDD);
            
            if WhatToPlot > 0
                figure
                plot(cumsum(obj.bktfastPaperTrading.outputbkt(:,4)))
                title(['Paper Trading Result, Final R over maxDD = ',num2str( risultato) ])
            end
            
            
            
        end % end function optimize
        
        
    end % end of methods
    
    
end % end of classdef