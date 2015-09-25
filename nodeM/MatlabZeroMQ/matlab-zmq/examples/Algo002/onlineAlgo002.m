function [ topicPub, messagePub ] = onlineAlgo002(topicSub,messageSub)
% TOPICSUB EX1: TIMEFRAMEQUOTE@MT4@ACTIVTRADES@EURUSD@m1@v1
% TOPICSUB EX2: MATLAB@111@EURUSD@STATUS
fprintf('topic: %s, message: %s\n', topicSub, messageSub);
pause(5)
% REMEMBER THE VAR 'TOPICPUB' SHOULD BE ONE STRING VALUE AS THE VALUES
% CONFIGURATED INTO THE FILE CONFIGPUBLISHERS.TXT
topicPub = 'MATLAB@111@EURUSD@OPERATIONS';
messagePub = '12';


listener1 = strcmp(topicSub,'TIMEFRAMEQUOTE@MT4@ACTIVTRADES@EURUSD@m30@v100');
listener2 = strcmp(topicSub,'TIMEFRAMEQUOTE@MT4@ACTIVTRADES@EURUSD@m1@v1');

newData = textscan(messageSub,'%d %d %d %d %d %s','Delimiter',','); % messageSub: open,max,min,close,volume,data

if listener1 == 1
    matrix(1:end-1,1)= newData(:,1);
    matrix(1:end-1,2)= newData(:,2);
    matrix(1:end-1,3)= newData(:,3);
    matrix(1:end-1,4)= newData(:,4);
    matrix(1:end-1,5)= newData(:,5);
    matrix(1:end-1,6)=datenum(newData{6}(:),'mm/dd/yyyy HH:MM');
    newTimeScalePoint=1; % controlla se ho dei nuovi dati sulla newTimeScale
    
elseif listener2 ==1
    matrix(end,1)= newData(:,1);
    matrix(end,2)= newData(:,2);
    matrix(end,3)= newData(:,3);
    matrix(end,4)= newData(:,4);
    matrix(end,5)= newData(:,5);
    matrix(end,6)=datenum(newData{6}(:),'mm/dd/yyyy HH:MM');    
end


%opening
% in sell con take profit e stop loss settati: op=-1, price=132, lot=1, slippage=05, sl=122, tp=142
% in buy senza take profit e stop loss settati: op=1, price=132, lot=1, slippage=05op=strcat('op=',num2str(open));
price=strcat('price=',num2str(openValue));
lots=strcat('lots=',num2str(1)); % for the moment we consider always lot=1
slippage=strcat('slippage=',num2str(1.5)); % for the opening slippage=1.5 pips
sl=strcat('sl=',num2str(stopLoss)); % not madatory
tp=strcat('tp=',num2str(takeProfit)); % not mandatory
topicPub='MATLAB@111@EURUSD@OPERATIONS';
messagePub=strcat(op,',',price,',',lots,',',slippage,',',sl,',',tp);

%closing: op=0, price=135, lot=1, slippage=02, ticket= 12345op=strcat('op=',num2str(0));
price=strcat('price=',num2str(closeValue));
lots=strcat('lots=',num2str(1)); % for the moment we consider always lot=1
slippage=strcat('slippage=',num2str(0.2)); % for the opening slippage=1.5 pips
ticket=strcat('ticket=',num2str(ticket1)); % ticket logic still to implement
topicPub='MATLAB@111@EURUSD@OPERATIONS';
messagePub=strcat(op,',',price,',',lots,',',slippage,',',ticket);



nData=100;
matrix=zeros(nData+1,6);
oper=0;
startingOperation = 0;
indexOpen = 0;
indexClose = 0;
k=0;

             
            lhisData = length(hisData);
            lnewHisData = length(obj.newHisData);
            direction = zeros(floor(lnewHisData/2), 1);
            openingPrice = zeros(floor(lnewHisData/2), 1);
            closingPrice = zeros(floor(lnewHisData/2), 1);
            openingDateNum = zeros(floor(lnewHisData/2), 1);
            closingDateNum = zeros(floor(lnewHisData/2), 1);
            nCandelotto = zeros(floor(lnewHisData/2), 1);
            lots = zeros(floor(lnewHisData/2), 1);
            jC = zeros(floor(lnewHisData/2), 1);
            iC = zeros(floor(lnewHisData/2), 1);
            iO = zeros(floor(lnewHisData/2), 1);
            SL = zeros(floor(lnewHisData/2), 1);
            TP = zeros(floor(lnewHisData/2), 1);
            
            ltimeSeriesproperties=floor(lhisData/newTimeScale)-(obj.nData*newTimeScale);
            obj.timeSeriesProperties=zeros(ltimeSeriesproperties,3);
            matrix=zeros(obj.nData+1, 6);
            

            for i = obj.nData:lnewHisData
                indexNewHisData=i-(obj.nData-1);
                matrix(1:obj.nData,:) = obj.newHisData(indexNewHisData:i,:);
                newTimeScalePoint=1; % controlla se ho dei nuovi dati sulla newTimeScale
                k=k+1;
                
                for j = 1:newTimeScale
                    
                    indexHisData=i*newTimeScale+j-1;
                    
                    if indexHisData > lhisData
                        break
                    end
                    
                    if isfinite(hisData(indexHisData,1))
                        matrix(end,:) = hisData(indexHisData,:);
                        [oper, openValue, closeValue, stopLoss, takeProfit, valueTp, st] = Algo_002_leadlag(matrix,newTimeScalePoint);
                        
                        newState{1} = oper;
                        newState{2} = openValue;
                        newState{3} = closeValue;
                        newState{4} = stopLoss;
                        newState{5} = takeProfit;
                        newState{6} = valueTp;
                        
                        a=st.HurstExponent;
                        b=st.pValue;
                        c=st.halflife;
                        if newTimeScalePoint && k>1;
                            obj.timeSeriesProperties(k-1,1)=a;
                            obj.timeSeriesProperties(k-1,2)=b;
                            obj.timeSeriesProperties(k-1,3)=c;
                        end
                        
                        newTimeScalePoint=0;
                        updatedOperation = newState{1};
                        
                        if abs(updatedOperation) > 0 && startingOperation == 0
                            
                            indexOpen = indexOpen + 1;
                            iO(indexOpen)=i;
                            SL(indexOpen)=stopLoss;
                            TP(indexOpen)=takeProfit;
                            
                            startingOperation = newState{1};
                            
                            display(['indexOpen =' num2str(indexOpen)]);
                            display(['i Open =' num2str(i)]);
                            display(['startingOperation =' num2str(startingOperation)]);
                            
                            
                            direction(indexOpen) = newState{1};
                            openingPrice(indexOpen) = newState{2};
                            openingDateNum(indexOpen) = obj.newHisData(i,6);
                            lots(indexOpen) = 1;
                            
                        elseif updatedOperation == 0 && abs(startingOperation) > 0
                            
                            jC(indexOpen)=indexHisData;
                            iC(indexOpen)=i;
                            nCandelotto(indexOpen) = i;
                            indexClose = indexClose + 1;
                            closingPrice(indexOpen) = newState{3};
                            closingDateNum(indexOpen) = obj.newHisData(i,6);
                            display(['closeValue =' num2str(closeValue)]);
                            startingOperation = 0;
                            display('operation closed');
                            display(['i Close =' num2str(i)]);
                            
                        end
                        
                    end
                    
                end
                
            end

            
            direction = direction(1:indexClose);
            openingPrice = openingPrice(1:indexClose);
            openingDateNum = openingDateNum(1:indexClose);
            closingDateNum = closingDateNum(1:indexClose);
            lots = lots(1:indexClose);
                      
            jC=jC(1:indexClose);
            iC=iC(1:indexClose);
            iO=iO(1:indexClose);
            SL=SL(1:indexClose);
            TP=TP(1:indexClose);
            
            l = length(direction);
            
            obj.iCloseActTimeScale=jC;
            obj.iCloseNewTimeScale=iC;
            obj.iOpenNewTimeScale=iO;
            obj.stopL=SL;
            obj.takeP=TP;
            
            obj.outputBktOffline = zeros(l,8);
            
            obj.outputBktOffline(:,1) = nCandelotto(1:l);           % index of stick
            obj.outputBktOffline(:,2) = openingPrice(1:l);          % opening price
            obj.outputBktOffline(:,3) = closingPrice(1:l);          % closing price
            obj.outputBktOffline(:,4) = (closingPrice(1:l) ...
                - openingPrice(1:l)) .* direction(1:l);             % returns
            obj.outputBktOffline(:,5) = direction(1:l);             % direction
            obj.outputBktOffline(:,6) = ones(l,1);                  % real
            obj.outputBktOffline(:,7) = openingDateNum;             % opening date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
            obj.outputBktOffline(:,8) = closingDateNum;             % closing date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
            obj.outputBktOffline(:,9) = lots;                       % lots setted for single operation
            
            
        end
        
    end
    
end







end
