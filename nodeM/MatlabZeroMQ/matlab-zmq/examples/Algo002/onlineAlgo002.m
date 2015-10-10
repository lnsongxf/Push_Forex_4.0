function [topicPub,messagePub] = onlineAlgo002(topicSub,messageSub)

persistent matrix;
persistent newTimeScalePoint;
persistent startingOperation;
persistent openValueReal;
persistent trial;
topicPub = '';
messagePub = '';
nData=80;

indexOpen = 0;
indexClose = 0;
k=0;

if(isempty(matrix))
    matrix = zeros(nData+1,6);
    startingOperation = 0;
end

if(isempty (openValueReal))
    openValueReal = 0;
end

listener1 = strcmp(topicSub,'TIMEFRAMEQUOTE@MT4@ACTIVTRADES@EURUSD@m30@v80');
listener2 = strcmp(topicSub,'TIMEFRAMEQUOTE@MT4@ACTIVTRADES@EURUSD@m1@v1');
listener3 = strcmp(topicSub,'MATLAB@111@EURUSD@STATUS');
if listener1 %new 30minutes data array
    myData = strsplit(messageSub, ';');
    for i = 1:length(myData)
        cells = strsplit(myData{i},',');
        matrix(i,1:5) = str2double(cells(1:5));
        matrix(i, 6) = datenum(cells{6},'mm/dd/yyyy HH:MM');
    end
    newTimeScalePoint=1; % controlla se ho dei nuovi dati sulla newTimeScale
    
elseif listener2 %new 1minute data point
    
    newData = textscan(messageSub,'%d %d %d %d %d %s','Delimiter',','); % messageSub: open,max,min,close,volume,data
    newDataMatrix = cell2mat(newData(1:5));
    matrix(end,1)= newDataMatrix(:,1);
    matrix(end,2)= newDataMatrix(:,2);
    matrix(end,3)= newDataMatrix(:,3);
    matrix(end,4)= newDataMatrix(:,4);
    matrix(end,5)= newDataMatrix(:,5);
    matrix(end,6)=datenum(newData{6}(:),'mm/dd/yyyy HH:MM');
    
    
elseif listener3 %new status
    
    newStatus = textscan(messageSub,'%d %s %d %d','Delimiter',','); % messageSub: status(1,-1),type(open,close),price,ticket
    status= newStatus(1);
    type= newStatus(2);
    price= newStatus(3);
    ticket= newStatus(4);
    
    open  = strcmp(type,'open');
    close = strcmp(type,'close');
    
    if open
        
        StatusOpen  = status;
        
        if StatusOpen == 1
            
            openValueReal = price ;
            text=strcat('MT4 opened the requested operation',num2str(ticket),'at the price',num2str(price));
            display (text);
            trial=1;
            
        elseif StatusOpen == -1
            
            display ('MT4 failed in opening the requested operation');
            openValueReal = -1 ;
            startingOperation = 0;
            
        end
        
    elseif close
        
        StatusClose = status;
        
        if StatusClose == 1
            
            text=strcat('MT4 closed the requested operation',num2str(ticket),'at the price',num2str(price));
            display (text);
            
        elseif StatusClose == -1
            
            text=strcat('MT4 failed in closing the operation',num2str(ticket));
            display (text);
            
            if trial < 5
                
                trial=trial+1;
                [topicPub,messagePub,startingOperation]=onlineClose(price,ticket,indexClose);
                text=strcat('Matlab trial #',num2str(trial),'to close the operation',num2str(ticket));
                display (text);
                
            end
            
        end
        
    end
end
    
    if listener1
        
        topicPub='';
        messagePub='';
        
    elseif listener2
        
        [oper, openValue, closeValue, stopLoss, takeProfit, valueTp, st] = Algo_002_leadlag(matrix,newTimeScalePoint,openValueReal);
        
        newState{1} = oper;
        newState{2} = openValue;
        newState{3} = closeValue;
        newState{4} = stopLoss;
        newState{5} = takeProfit;
        newState{6} = valueTp;
        
        newTimeScalePoint=0;
        updatedOperation = newState{1};
        
        a=st.HurstExponent;
        b=st.pValue;
        c=st.halflife;
        
        if newTimeScalePoint && k>1;
            
            timeSeriesProperties(k-1,1)=a;
            timeSeriesProperties(k-1,2)=b;
            timeSeriesProperties(k-1,3)=c;
            
        end
        
        if abs(updatedOperation) > 0 && startingOperation == 0
            
            % Opening request
            [topicPub,messagePub,startingOperation]=onlineOpen(oper,openValue,stopLoss,takeProfit,indexOpen);
            
            
        elseif updatedOperation == 0 && abs(startingOperation) > 0
            % Closing request
            [topicPub,messagePub,startingOperation]=onlineClose(closeValue,ticket,indexClose);
            
        end
    end
    
end


