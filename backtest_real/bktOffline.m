classdef bktOffline < handle
    
    properties
        newHisData
        outputBktOffline
        performance
    end
    
    methods
 
        function [obj] = spin(obj,nameAlgo,cross,nData,histName,actTimeScale, ... 
                newTimeScale,transCost,initialStack,leverage)
            
            %
            % per salvare lo storico:
            % dlmwrite('EURUSD_2012_2015.csv', data, '-append') ;
            %
            % DESCRIPTION:
            % -------------------------------------------------------------
            % This function runs the offline backtest on given historical data
            %
            %
            % INPUT parameters:
            % -------------------------------------------------------------
            % nameAlgo: nome dell'algoritmo che usi
            % cross: ad es 'EURUSD'
            % nData: numero di dati in input di storico per ciclo
            % histName: nome dello storico, es: 'nome_storico.csv'
            % actTimeScale: scala temporale dello storico in input
            % newTimeScale: scala temporale su cui vuoi lavorare (in minuti)
            % transCost: costo dello spread in pips, ad es: 1
            % initialStack: capitale iniziale, ad es: 10000
            % leverage: la leva che usi, es: 10
            %
            % OUTPUT parameters:
            % -------------------------------------------------------------
            %
            %
            %
            % EXAMPLE of use:
            % -------------------------------------------------------------
            % clear all; bkt_AlgoX=bktOffline
            % bkt_AlgoX=bkt_AlgoX.spin('Algo_Ale_02','EURUSD',100,'EURUSD_2012_2015.csv',1,5,1,10000,10)
            %

            hisData = csvread(histName);
            [r,c] = size(hisData);
            startingOperation = 0;
            indexOpen = 0;
            indexClose = 0;
            
            % includi colonna delle date se non esiste nel file di input
            if c == 5

                hisData(1,6) = datenum('01/01/2015 00:00', 'mm/dd/yyyy HH:MM');
                
                for j = 2:r;                
                    hisData(j,6) = hisData(1,6) + ( (actTimeScale/1440)*(j-1) );
                end
                
            end
                     
            % riscala temporalmente se richiesto
            if newTimeScale > 1

                expert = TimeSeriesExpert_11;
                expert.rescaleData(hisData,actTimeScale,newTimeScale)
                
                obj.newHisData(:,1) = expert.openVrescaled;
                obj.newHisData(:,2) = expert.maxVrescaled;
                obj.newHisData(:,3) = expert.minVrescaled;
                obj.newHisData(:,4) = expert.closeVrescaled;
                obj.newHisData(:,5) = expert.volrescaled;
                obj.newHisData(:,6) = expert.openDrescaled;               

            else
                
                obj.newHisData = hisData;
            
            end
            
            
            ls = length(obj.newHisData);
            direction = zeros(floor(ls/2), 1);
            openingPrice = zeros(floor(ls/2), 1);
            closingPrice = zeros(floor(ls/2), 1);
            openingDateNum = zeros(floor(ls/2), 1);
            closingDateNum = zeros(floor(ls/2), 1);
            nCandelotto = zeros(floor(ls/2), 1);
            lots = zeros(floor(ls/2), 1);
            
            % da qui inizia il core dello spin
            tic
            
            for i = nData:ls
                matrix = obj.newHisData(i-(nData-1):i,:);
                
                for j = 1:newTimeScale
                  matrix(end, 4) = hisData(i*newTimeFrame + j, 4);
                  [oper, openValue, closeValue, stopLoss, noLoose, valueTp] = Algo_004_Ale(matrix);
                
                  newState{1} = oper;
                  newState{2} = openValue;
                  newState{3} = closeValue;
                  newState{4} = stopLoss;
                  newState{5} = noLoose;
                  newState{6} = valueTp;
                
                  updatedOperation = newState{1};
                
                  if abs(updatedOperation) > 0 && startingOperation == 0
                    
                      indexOpen = indexOpen + 1;
                      startingOperation = newState{1};
                    
                      display(['indexOpen =' num2str(indexOpen)]);
                      display(['startingOperation =' num2str(startingOperation)]);


                    
                      direction(indexOpen) = newState{1};
                      openingPrice(indexOpen) = newState{2};
                      openingDateNum(indexOpen) = obj.newHisData(i,6);
                      lots(indexOpen) = 1;
                    
                  elseif updatedOperation == 0 && abs(startingOperation) > 0
                    
                    nCandelotto(indexOpen) = i;
                    indexClose = indexClose + 1;
                    closingPrice(indexOpen) = newState{3};
                    closingDateNum(indexOpen) = obj.newHisData(i,6);
                    display(['closeValue =' num2str(closeValue)]);
                    startingOperation = 0;
                    display('operation closed');

                    
                  end
                  
                end
                
            end
            
            toc
            
            direction = direction(1:indexClose);
            openingPrice = openingPrice(1:indexClose);
            openingDateNum = openingDateNum(1:indexClose);
            closingDateNum = closingDateNum(1:indexClose);
            lots = lots(1:indexClose);
            l = length(direction);
            
            obj.outputBktOffline = zeros(l,8);
            
            obj.outputBktOffline(:,1) = nCandelotto(1:l);       % index of stick
            obj.outputBktOffline(:,2) = openingPrice(1:l);      % opening price
            obj.outputBktOffline(:,3) = closingPrice(1:l);        % closing price
            obj.outputBktOffline(:,4) = (closingPrice(1:l) ...
                - openingPrice(1:l)) .* direction(1:l);                % returns
            obj.outputBktOffline(:,5) = direction(1:l);             % direction
            obj.outputBktOffline(:,6) = ones(l,1);                  % real
            obj.outputBktOffline(:,7) = openingDateNum;      % opening date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
            obj.outputBktOffline(:,8) = closingDateNum;        % closing date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
            obj.outputBktOffline(:,9) = lots;                           % lots setted for single operation
            
            %             p = Performance_04;
            %             obj.performance = p.calcSinglePerformance(nameAlgo,'bktWeb',cross,newTimeScale,transCost,obj.outputBktOffline);
            
            p = Performance_05;
            obj.performance = p.calcSinglePerformance(nameAlgo,'bktWeb',cross,newTimeScale,transCost,initialStack,leverage,obj.outputBktOffline);
            
            
        end
        
    end
    
end
    
    
