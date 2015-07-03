classdef bktOffline < handle
    
    properties
        newHisData
        outputBktOffline
    end
    
    methods
 
        function [obj]=spin(obj,nData,histName,newTimeScale)
            % Commenti al codice sono contrassegnati da by_ivan
            % In generale e' molto ben fatto e non vedo errori particolari.
            % Per ora non ho matlab e' non posso fare il debug, aspetto Simone che crei la macchina virtuale,
            % ma se gia' facessi il push del dummy storico e del'algo di test, potrei darti un'idea piu' precisa.
            % Se lo hai gia' fatto, non sono riuscito a trovare i file.
            %
            % DESCRIPTION:
            % -------------------------------------------------------------
            % This function runs the offline backtest on given historical data
            %
            %
            % INPUT parameters:
            % -------------------------------------------------------------
            % nData             ...
            % histName          ... 'storico.csv'
            %                   ...
            %                   ...
            %
            % OUTPUT parameters:
            % -------------------------------------------------------------
            %
            %
            %
            % EXAMPLE of use:
            % -------------------------------------------------------------
            % bkt_AlgoX=bktOffline
            % bkt_AlgoX=bkt_AlgoX.spin(10,'dummy_hist.csv',2)
            %
            
            hisData = csvread(histName);
            startingOperation=0;
            indexOpen=0;
            indexClose=0;
            
            if newTimeScale>1
                expert=TimeSeriesExpert_11;
                expert.rescaleData(hisData,1,newTimeScale)
                
                obj.newHisData(:,1)=expert.openVrescaled;
                obj.newHisData(:,2)=expert.maxVrescaled;
                obj.newHisData(:,3)=expert.minVrescaled;
                obj.newHisData(:,4)=expert.closeVrescaled;
                obj.newHisData(:,5)=expert.volrescaled;
                obj.newHisData(:,6)=expert.openDrescaled;
                
            else
                obj.newHisData=hisData;
            end
            
            ls=length(obj.newHisData);
            direction=zeros(floor(ls/2), 1);
            openingPrice=zeros(floor(ls/2), 1);
            closingPrice=zeros(floor(ls/2), 1);
            
            tic
            for i=nData:ls
                
                [oper, openValue, closeValue, stopLoss, noLoose, valueTp] = Algo_002_Ale(obj.newHisData(i-(nData-1):i,:));
                
                newState{1}=oper;
                newState{2}=openValue;
                newState{3}=closeValue;
                newState{4}=stopLoss;
                newState{5}=noLoose;
                newState{6}=valueTp;
                
                updatedOperation=newState{1};
                
                if abs(updatedOperation)>0 && startingOperation==0
                    indexOpen=indexOpen+1;
                    startingOperation=newState{1};
                    
                    display(indexOpen);
                    display(startingOperation);
                    
                    direction(indexOpen)=newState{1};
                    openingPrice(indexOpen)=newState{2};
                    
                elseif updatedOperation==0 && abs(startingOperation)>0
                    indexClose=indexClose+1;
                    closingPrice(indexOpen)=newState{3};
                    display(closeValue);
                    startingOperation=0;
                    display('operation closed');
                end
                
            end
            
            toc
            
            direction=direction(1:indexClose);
            openingPrice=openingPrice(1:indexClose);
            l=length(direction);
            
            obj.outputBktOffline=zeros(l,8);
            
            % outputBktOffline(:,1)=nCandelotto;           % index of stick
            obj.outputBktOffline(:,2)=openingPrice(1:l);          % opening price
            obj.outputBktOffline(:,3)=closingPrice(1:l);          % closing price
            % outputBktOffline(:,4)=matrixWeb(:,4);        % returns
            obj.outputBktOffline(:,5)=direction(1:l);             % direction
            obj.outputBktOffline(:,6)=ones(l,1);              % real
            % outputBktOffline(:,7)=openingDateNum;        % opening date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
            % outputBktOffline(:,8)=closingDateNum;        % closing date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
            
        end
        
    end
    
end
    
    
