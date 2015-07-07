classdef bktOffline < handle
    
    properties
        newHisData
        outputBktOffline
        performance
    end
    
    methods
 
        function [obj]=spin(obj,nameAlgo,cross,nData,histName,actTimeScale,newTimeScale,transCost)
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
            % clear all; bkt_AlgoX=bktOffline
            % bkt_AlgoX=bkt_AlgoX.spin(10,'dummy_hist.csv',1,60)
            %
            
            hisData = csvread(histName);
            [r,c]=size(hisData);
            startingOperation=0;
            indexOpen=0;
            indexClose=0;
            
            if c==5
                hisData(1,6)=datenum('01/01/2015 00:00', 'mm/dd/yyyy HH:MM');
                for j=2:r;
                    hisData(j,6)=hisData(1,6)+((actTimeScale/1440)*(j-1));
                end
            end
                     
            if newTimeScale>1
                expert=TimeSeriesExpert_11;
                expert.rescaleData(hisData,actTimeScale,newTimeScale)
                
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
            openingDateNum=zeros(floor(ls/2), 1);
            closingDateNum=zeros(floor(ls/2), 1);
            nCandelotto=zeros(floor(ls/2), 1);
            
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
                    openingDateNum(indexOpen)=obj.newHisData(i,6);
                    
                elseif updatedOperation==0 && abs(startingOperation)>0
                    nCandelotto(indexOpen)=i;
                    indexClose=indexClose+1;
                    closingPrice(indexOpen)=newState{3};
                    closingDateNum(indexOpen)=obj.newHisData(i,6);
                    display(closeValue);
                    startingOperation=0;
                    display('operation closed');
                end
                
            end
            
            toc
            
            direction=direction(1:indexClose);
            openingPrice=openingPrice(1:indexClose);
            openingDateNum=openingDateNum(1:indexClose);
            closingDateNum=closingDateNum(1:indexClose);
            l=length(direction);
            
            obj.outputBktOffline=zeros(l,8);
            
            obj.outputBktOffline(:,1)=nCandelotto(1:l);           % index of stick
            obj.outputBktOffline(:,2)=openingPrice(1:l);          % opening price
            obj.outputBktOffline(:,3)=closingPrice(1:l);          % closing price
            obj.outputBktOffline(:,4)=(closingPrice(1:l) - openingPrice(1:l)).*direction(1:l);        % returns
            obj.outputBktOffline(:,5)=direction(1:l);             % direction
            obj.outputBktOffline(:,6)=ones(l,1);              % real
            obj.outputBktOffline(:,7)=openingDateNum;        % opening date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
            obj.outputBktOffline(:,8)=closingDateNum;        % closing date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
            
            
            p=Performance_04;
            obj.performance=p.calcSinglePerformance(nameAlgo,'bktWeb',cross,newTimeScale,transCost,obj.outputBktOffline);
            
        end
        
    end
    
end
    
    
