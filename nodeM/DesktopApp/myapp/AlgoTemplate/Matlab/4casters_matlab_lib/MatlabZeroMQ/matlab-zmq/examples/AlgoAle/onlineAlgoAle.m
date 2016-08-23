function [topicPub,messagePub] = onlineAlgoAle(topicSub,messageSub)

persistent matrix;
% persistent newTimeScalePoint;
persistent startingOperation;
persistent updatedOperation;
persistent openValueReal;
persistent trial;
persistent ticket;

topicPub = '';
messagePub = '';
nData=100;

indexOpen = 0;
indexClose = 0;
k=0;

if(isempty(matrix))
    matrix = zeros(nData+1,6);
    startingOperation = 0;
    ticket = -1;
    updatedOperation = 0;
end

if(isempty (openValueReal))
    openValueReal = 0;
end

listener1 = strcmp(topicSub,'TIMEFRAMEQUOTE@MT4@ACTIVTRADES@EURUSD@m30@v100');
listener2 = strcmp(topicSub,'TIMEFRAMEQUOTE@MT4@ACTIVTRADES@EURUSD@m1@v1');
listener3 = strcmp(topicSub,'STATUS@EURUSD@1000');

if listener1 %new 30minutes data array
    
    display('new data array at 30min');
    myData = strsplit(messageSub, ';');
    
    for i = 1:length(myData)
        
        cells = strsplit(myData{i},',');
        matrix(i,1:5) = str2double(cells(1:5));
        matrix(i, 6) = datenum(cells{6},'mm/dd/yyyy HH:MM');
        
    end
    
    matrix(:,end)=matrix(:,end-1); % copio l'ultima mezz ora cm se fosse il dato al minuto
    
elseif listener2 %new 1minute data point
    
    display('new data point at 1min');
    newData = textscan(messageSub,'%d %d %d %d %d %s','Delimiter',','); % messageSub: open,max,min,close,volume,data
    newDataMatrix = cell2mat(newData(1:5));
    matrix(end,1)= newDataMatrix(:,1);
    matrix(end,2)= newDataMatrix(:,2);
    matrix(end,3)= newDataMatrix(:,3);
    matrix(end,4)= newDataMatrix(:,4);
    matrix(end,5)= newDataMatrix(:,5);
    matrix(end,6)=datenum(newData{6}(:),'mm/dd/yyyy HH:MM');
    
    
elseif listener3 %new status
    
    display(strcat('Topic: ', topicSub));
    display(strcat('Message: ', messageSub));
    newStatus = textscan(messageSub,'%d %s %d %d','Delimiter',','); % messageSub: status(1,-1),type(open,close),price,ticket
    status= newStatus{1};
    type= newStatus{2};
    price= newStatus{3};
    abc= newStatus{4};
    ticket = abc;
    
     display( strcat('Ticket: ', num2str(ticket)) );
%      display( strcat('Type: ', type) );
     display( strcat('Price: ', num2str(price)) );
    
    open  = strcmp(type,'open');
    close = strcmp(type,'close');
    
    if open
        
        StatusOpen  = status;
        
        if StatusOpen == 1
            
            openValueReal = price ;
            display(strcat('MT4 opened the requested operation ',num2str(ticket),' at the price ',num2str(price)) );
            trial=1;
            
        elseif StatusOpen == -1
            
            display ('MT4 failed in opening the requested operation. Won t try again');
            openValueReal = -1 ;
            startingOperation = 0;
            
        end
        
    elseif close
        
        StatusClose = status;
        
        if StatusClose == 1
            
            display( strcat('MT4 closed the requested operation ',num2str(ticket),' at the price ',num2str(price)) );
            
        elseif StatusClose == -1
            
            display( strcat('MT4 failed in closing the operation ',num2str(ticket)) );
            
            %if trial < 5
            
            trial=trial+1;
            [topicPub,messagePub,startingOperation]=onlineCloseAle(price,ticket,indexClose);
            display( strcat('Matlab trial #',num2str(trial),' to close the operation ',num2str(ticket)) );
            
            %end
            
        end
        
    end
end

[oper, openValue, closeValue, stopLoss, takeProfit, valueTp, st] = Algo_002_leadlag(matrix,1,openValueReal);

newState{1} = oper;
newState{2} = openValue;
newState{3} = closeValue;
newState{4} = stopLoss;
newState{5} = takeProfit;
newState{6} = valueTp;

updatedOperation = newState{1};

%     a=st.HurstExponent;
%     b=st.pValue;
%     c=st.halflife;
%
%     if  k>1;
%
%         timeSeriesProperties(k-1,1)=a;
%         timeSeriesProperties(k-1,2)=b;
%         timeSeriesProperties(k-1,3)=c;
%
%     end

if abs(updatedOperation) > 0 && startingOperation == 0
    
    % Opening request
    % ACHTUNG: The SL and TP values are sent as tenths of pips, so we have
    % to multiply by 10 to get the correct pips. I also incremented the
    % numbers to avoid Metatrader to close automatically
    [topicPub,messagePub,startingOperation]=onlineOpenAle(oper,openValue,stopLoss*10+500,takeProfit*10+1000,indexOpen);
    pause(10); % just to be sure to wait enough before restarting
    
    
elseif updatedOperation == 0 && abs(startingOperation) > 0
    % Closing request
    [topicPub,messagePub,startingOperation]=onlineCloseAle(closeValue,ticket,indexClose);
    pause(10); % just to be sure to wait enough before restarting
    
end


end


