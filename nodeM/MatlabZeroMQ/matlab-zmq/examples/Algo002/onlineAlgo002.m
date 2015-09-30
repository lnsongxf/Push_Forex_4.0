function [topicPub,messagePub] = onlineAlgo002(topicSub,messageSub)

persistent matrix;
persistent newTimeScalePoint;
persistent startingOperation;
nData=100;

indexOpen = 0;
indexClose = 0;
k=0;

if(isempty(matrix))
    matrix = zeros(nData+1,6);
end

listener1 = strcmp(topicSub,'TIMEFRAMEQUOTE@MT4@ACTIVTRADES@EURUSD@m30@v100');
listener2 = strcmp(topicSub,'TIMEFRAMEQUOTE@MT4@ACTIVTRADES@EURUSD@m1@v1');
listener3 = strcmp(topicSub,'MATLAB@111@EURUSD@STATUS');

if listener1 == 1
    newData = textscan(messageSub,'%d %d %d %d %d %s','Delimiter',','); % messageSub: open,max,min,close,volume,data
    matrix(1:end-1,1)= newData(:,1);
    matrix(1:end-1,2)= newData(:,2);
    matrix(1:end-1,3)= newData(:,3);
    matrix(1:end-1,4)= newData(:,4);
    matrix(1:end-1,5)= newData(:,5);
    matrix(1:end-1,6)=datenum(newData{6}(:),'mm/dd/yyyy HH:MM');
    newTimeScalePoint=1; % controlla se ho dei nuovi dati sulla newTimeScale
    
elseif listener2 == 1
    newData = textscan(messageSub,'%d %d %d %d %d %s','Delimiter',','); % messageSub: open,max,min,close,volume,data
    matrix(end,1)= newData(:,1);
    matrix(end,2)= newData(:,2);
    matrix(end,3)= newData(:,3);
    matrix(end,4)= newData(:,4);
    matrix(end,5)= newData(:,5);
    matrix(end,6)=datenum(newData{6}(:),'mm/dd/yyyy HH:MM');
    
elseif listener3 == 1
    newStatus = textscan(messageSub,'%d %s %d %d','Delimiter',','); % messageSub: status(1,-1),type(buy,sell),price,ticket
    status= newStatus(1);
    type= newStatus(2);
    price= newStatus(3);
    ticket= newStatus(4);
end

if listener1
    
    topicPub='';
    messagePub='';
    
elseif listener2
    
    [oper, openValue, closeValue, stopLoss, takeProfit, valueTp, st] = Algo_002_leadlag(matrix,newTimeScalePoint);
    
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
        
        indexOpen = indexOpen + 1;
        display(['indexOpen =' num2str(indexOpen)]);
        startingOperation = newState{1};
        display(['startingOperation =' num2str(startingOperation)]);
        
        
    elseif updatedOperation == 0 && abs(startingOperation) > 0
        
        %closing 
        % example: op=0, price=135, lot=1, slippage=02, ticket= 12345op=strcat('op=',num2str(0));
        price=strcat('price=',num2str(closeValue));
        lots=strcat('lots=',num2str(1)); % for the moment we consider always lot=1
        slippage=strcat('slippage=',num2str(0.2)); % for the opening slippage=1.5 pips
        ticket=strcat('ticket=',num2str(ticket1)); % ticket logic still to implement
        topicPub='MATLAB@111@EURUSD@OPERATIONS';
        messagePub=strcat(op,',',price,',',lots,',',slippage,',',ticket);
        
        indexClose = indexClose + 1;
        display(['indexClose =' num2str(indexClose)]);
        display(['closeValue =' num2str(closeValue)]);
        startingOperation = 0;
        display('operation closed');
        
    end
    
end

end


