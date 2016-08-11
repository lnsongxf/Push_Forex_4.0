classdef bktOffline_02 < handle
    
    properties
        nData
        starthisData
        newHisData
        iOpenActTimeScale
        iCloseActTimeScale
        iOpenNewTimeScale
        iCloseNewTimeScale
        stopL
        takeP
        outputBktOffline
        performance
        performanceDistribution
        timeSeriesProperties
        timeSeriesPropertiesOffline
    end
    
    methods
        
        function [obj] = spin(obj,parameters)
            
            %
            % DESCRIPTION:
            % -------------------------------------------------------------
            % This function runs the offline backtest on given historical data
            %
            % INPUT parameters:
            % -------------------------------------------------------------
            % nameAlgo:                 nome esatto dell'algoritmo che usi
            % Cross:                    ad es 'EURUSD'
            % nData:                    numero di dati in input di storico per ciclo
            % histName:                 nome dello storico, es: 'nome_storico.csv'
            % actTimeScale:             scala temporale dello storico in input
            % newTimeScale:             scala temporale su cui vuoi lavorare (in minuti)
            % transCost:                costo dello spread in pips, ad es: 1
            % initialStack:             capitale iniziale, ad es: 10000
            % Leverage:                 la leva che usi, es: 10
            % plotPerformance:          1 se vuoi plottare le perfomance
            % plotPerDistribution:      1-microanalisi 2-macroanalisi 3-pattern ritorni
            %                           4-plot operazioni su storico 5-plotta tutto
            %
            % OUTPUT parameters:
            % -------------------------------------------------------------
            % starthisData
            % newHisData
            % iCloseActTimeScale
            % iCloseNewTimeScale
            % iOpenNewTimeScale
            % stopL
            % takeP
            % outputBktOffline
            % performance
            % performanceDistribution
            %
            % EXAMPLE of use:
            % -------------------------------------------------------------
            % clear all; bkt_Algo_002=bktOffline_02
            % bkt_Algo_002=bkt_Algo_002.spin('parameters_Offline_Algo_002.txt')
            %
            % NOTE
            % -------------------------------------------------------------
            % per salvare lo storico:   dlmwrite('EURUSD_2012_2015.csv', data, '-append') ;
            %
            
            %% Import parameters:
            fid=fopen(parameters);
            C = textscan(fid, '%s', 'Delimiter', '', 'CommentStyle', '%');
            fclose(fid);
            cellfun(@eval, C{1});
            
            algo = str2func(nameAlgo);
            
            obj.nData=nData_;
            
            [histData, newHistData] = load_historical_02(histName, actTimeScale, newTimeScale);
            obj.starthisData = histData;
            obj.newHisData   = newHistData;
            
            startingOperation = 0;
            openValueReal = 0;
            indexOpen = 0;
            indexClose = 0;
            k = 0;
 
            lhisData       = length(histData);
            lnewHisData    = length(obj.newHisData);
            direction      = zeros(floor(lnewHisData/2), 1);
            openingPrice   = zeros(floor(lnewHisData/2), 1);
            closingPrice   = zeros(floor(lnewHisData/2), 1);
            openingDateNum = zeros(floor(lnewHisData/2), 1);
            closingDateNum = zeros(floor(lnewHisData/2), 1);
            nCandelotto    = zeros(floor(lnewHisData/2), 1);
            minimumReturns = zeros(floor(lnewHisData/2), 1);
            lots           = zeros(floor(lnewHisData/2), 1);
            jC             = zeros(floor(lnewHisData/2), 1);   % index j close
            iC             = zeros(floor(lnewHisData/2), 1);   % index i close
            iO             = zeros(floor(lnewHisData/2), 1);   % index i open
            SL             = zeros(floor(lnewHisData/2), 1);   % stop loss
            TP             = zeros(floor(lnewHisData/2), 1);   % take profit
            
            matrix=zeros(obj.nData+1, 6);
            
            obj.timeSeriesProperties=indicators;
            obj.timeSeriesPropertiesOffline=indicatorsOffline;
            
            %% ---  da qui inizia il core dello spin ---
            tic
            
            % l'indice i è sui dati alla new time scale
            for i = obj.nData:lnewHisData
                
                indexNewHisData=i-(obj.nData-1);
                matrix(1:obj.nData,:) = obj.newHisData(indexNewHisData:i,:);
                newTimeScalePoint=1; % controlla se ho dei nuovi dati sulla newTimeScale
                newTimeScalePointEnd = 0;
                k=k+1; % serve solo nel calcolo della probabilità di mean reversion etc...
                
                % l'indice j è sui dati al minuto (alla time scale più veloce)
                for j = 1:newTimeScale
                    
                    if j == newTimeScale
                        newTimeScalePointEnd = 1;
                    end
                    
                    indexHisData=i*newTimeScale+j-1;
                    
                    % check se ho sforato oltre l'ultimo punto dello storico
                    if indexHisData > lhisData
                        break
                    end
                    
                    % se nn ho un buco NaN nello storico...
                    if isfinite(histData(indexHisData,1))
                        
                        matrix(end,:) = histData(indexHisData,:);
                        
                        [oper,openValue, closeValue, stopLoss, takeProfit, minReturn] = algo(matrix,newTimeScalePoint,newTimeScalePointEnd,openValueReal,obj.timeSeriesProperties,indexHisData);

                        newState{1} = oper;
                        newState{2} = openValue;
                        newState{3} = closeValue;
                        newState{4} = stopLoss;
                        newState{5} = takeProfit;
                        newState{6} = minReturn;
                        
                        if newTimeScalePoint == 1 && k > 1
                            obj.timeSeriesPropertiesOffline.HurstExponent(k-1,1) = obj.timeSeriesProperties.HurstExponent(end);
                            obj.timeSeriesPropertiesOffline.HurstDiff(k-1,1) = obj.timeSeriesProperties.HurstDiff(end);
                            obj.timeSeriesPropertiesOffline.pValue (k-1,1) = obj.timeSeriesProperties.pValue(end);
                            obj.timeSeriesPropertiesOffline.halflife(k-1,1) = obj.timeSeriesProperties.halflife(end);
                            if k >= 101
                            obj.timeSeriesPropertiesOffline.HurstSmooth(k-100:k-1,1) = obj.timeSeriesProperties.HurstSmooth;
                            end
                        end
                        
                        newTimeScalePoint=0;
                        updatedOperation = newState{1};
     
                        %opening
                        if abs(updatedOperation) > 0 && startingOperation == 0
                            
                            openValueReal             = newState{2};
                            startingOperation         = newState{1};
                            
                            indexOpen = indexOpen + 1;
                            iO(indexOpen)=i;
                            SL(indexOpen)=stopLoss;
                            TP(indexOpen)=takeProfit;
                            
                            display(['indexOpen =' num2str(indexOpen)]);
                            display(['i Open =' num2str(i)]);
                            display(['startingOperation =' num2str(startingOperation)]);
                            
                            direction(indexOpen)      = newState{1};
                            openingPrice(indexOpen)   = newState{2};
                            openingDateNum(indexOpen) = obj.newHisData(i,6);
                            lots(indexOpen)           = 1;
                            
                        % closing
                        elseif updatedOperation == 0 && abs(startingOperation) > 0
                            
                            openValueReal     = 0;
                            startingOperation = 0;
                            display(['closeValue =' num2str(closeValue)]);
                            display('operation closed');
                            display(['i Close =' num2str(i)]);
                            
                            minimumReturns(indexOpen) = newState{6};
                            jC(indexOpen)             = indexHisData;
                            iC(indexOpen)             = i;
                            nCandelotto(indexOpen)    = i;
                            indexClose                = indexClose + 1;
                            closingPrice(indexOpen)   = newState{3};
                            closingDateNum(indexOpen) = obj.newHisData(i,6);
                            
                        end
                        
                    end
                    
                end
                
            end
            
            toc
            
            iO=iO(1:indexClose);
            iC=iC(1:indexClose);
            jO=iO*newTimeScale;
            jC=jC(1:indexClose);
            SL=SL(1:indexClose);
            TP=TP(1:indexClose);   
            
            obj.iOpenNewTimeScale  = iO;
            obj.iCloseNewTimeScale = iC;
            obj.iOpenActTimeScale  = jO;
            obj.iCloseActTimeScale = jC;
            obj.stopL=SL;
            obj.takeP=TP;
            
            direction       = direction(1:indexClose);
            openingPrice    = openingPrice(1:indexClose);
            openingDateNum  = openingDateNum(1:indexClose);
            closingDateNum  = closingDateNum(1:indexClose);
            minimumReturns  = minimumReturns(1:indexClose);
            lots            = lots(1:indexClose);
            latency         = jC-jO;
        
            l = length(direction);
            obj.outputBktOffline = zeros(l,8);
            
            obj.outputBktOffline(:,1)  = nCandelotto(1:l);           % index of stick
            obj.outputBktOffline(:,2)  = openingPrice(1:l);          % opening price
            obj.outputBktOffline(:,3)  = closingPrice(1:l);          % closing price
            obj.outputBktOffline(:,4)  = (closingPrice(1:l) ...
                - openingPrice(1:l)) .* direction(1:l);              % returns
            obj.outputBktOffline(:,5)  = direction(1:l);             % direction
            obj.outputBktOffline(:,6)  = ones(l,1);                  % real
            obj.outputBktOffline(:,7)  = openingDateNum;             % opening date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
            obj.outputBktOffline(:,8)  = closingDateNum;             % closing date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
            obj.outputBktOffline(:,9)  = lots;                       % lots setted for single operation
            obj.outputBktOffline(:,10) = latency;                    % duration of single operation
            obj.outputBktOffline(:,11) = minimumReturns;             % minimum return touched during dingle operation

            p = Performance_07;
            obj.performance = p.calcSinglePerformance(nameAlgo,'bktWeb',histName,Cross,newTimeScale,transCost,initialStack,Leverage,obj.outputBktOffline,plotPerformance);
            pD = PerformanceDistribution_05;
            obj.performanceDistribution = pD.calcPerformanceDistr(nameAlgo,'bktWeb',Cross,obj.nData,newTimeScale,transCost,obj.outputBktOffline,obj.timeSeriesPropertiesOffline,obj.starthisData,obj.newHisData,15,10,10,plotPerDistribution);
            
        end
        
    end
    
end


