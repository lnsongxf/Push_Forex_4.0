function [topicPub,messagePub] = onlineAlgo002(topicSub,messageSub,password)

persistent matrix;
persistent newTimeScalePoint;
persistent startingOperation;
persistent updatedOperation;
persistent openValueReal;
persistent trial;
persistent ticket;
persistent ms;
persistent tStartClosingRequest;
persistent tElapsedClosingRequest;

topicPub = '';
messagePub = '';
nData=80;
closingTimeScale = 1;
openingTimeScale = 30;

indexOpen = 0;
indexClose = 0;

if(isempty(matrix))
    matrix = zeros(nData+1,6);
    startingOperation = 0;
    ticket = -1;
    updatedOperation = 0;
    newTimeScalePoint = 0;
    ms = machineStateManager;
    ms.machineStatus = 'closed';
end

if(isempty (openValueReal))
    openValueReal = 0;
end

listener1 = strcmp(topicSub,'TIMEFRAMEQUOTE@MT4@ACTIVTRADES@EURUSD@m1@v80');
listener2 = strcmp(topicSub,'TIMEFRAMEQUOTE@MT4@ACTIVTRADES@EURUSD@m1@v1');
listener3 = strcmp(topicSub,'STATUS@EURUSD@1002');

if listener1 && ( strcmp(ms.machineStatus,'closed') || strcmp(ms.machineStatus,'open') ) %new 30minutes data array
    
    display('new data array at 30min');
    myData = strsplit(messageSub, ';');
    newTimeScalePoint = 1;
    
    for i = 1:length(myData)
        
        cells = strsplit(myData{i},',');
        matrix(i,1:5) = str2double(cells(1:5));
        matrix(i, 6) = datenum(cells{6},'mm/dd/yyyy HH:MM');
        
    end
    
    matrix(:,end)=matrix(:,end-1); % copio l'ultima mezz ora cm se fosse il dato al minuto
    
elseif listener2 && ( strcmp(ms.machineStatus,'closed') || strcmp(ms.machineStatus,'open') ) %new 1minute data point
    
    display('new data point at 1min');
    newData = textscan(messageSub,'%d %d %d %d %d %s','Delimiter',','); % messageSub: open,max,min,close,volume,data
    newDataMatrix = cell2mat(newData(1:5));
    matrix(end,1)= newDataMatrix(:,1);
    matrix(end,2)= newDataMatrix(:,2);
    matrix(end,3)= newDataMatrix(:,3);
    matrix(end,4)= newDataMatrix(:,4);
    matrix(end,5)= newDataMatrix(:,5);
    matrix(end,6)=datenum(newData{6}(:),'mm/dd/yyyy HH:MM');
    
    
elseif listener3 && ( strcmp(ms.machineStatus,'closing') || strcmp(ms.machineStatus,'opening') )%new status
    
    display(strcat('Topic:',{' '}, topicSub));
    display(strcat('Message:',{' '}, messageSub));
    newStatus = textscan(messageSub,'%d %s %d %d','Delimiter',','); % messageSub: status(1,-1),type(open,close),price,ticket
    status= newStatus{1};
    type= newStatus{2};
    price= newStatus{3};
    abc= newStatus{4};
    ticket = abc;
    
    display( strcat('Ticket:',{' '}, num2str(ticket)) );
    display( strcat('Price:',{' '}, num2str(price)) );
    
    open  = strcmp(type,'open');
    close = strcmp(type,'close');
    
    if open
        
        StatusOpen  = status;
        
        if StatusOpen == 1
            
            openValueReal = price ;
            display(strcat('MT4 opened the requested operation ',{' '},num2str(ticket),{' '},' at the price ',{' '},num2str(price)) );
            ms.machineStatus = 'open';
            display(ms.machineStatus);
            trial=1;
            
            pause(30) % wait the next 1 min data point
            
        elseif StatusOpen == -1
            
            display ('MT4 failed in opening the requested operation. Won t try again');
            openValueReal = -1 ;
            startingOperation = 0;
            ms.machineStatus = 'closed';
            
        end
        
    elseif close
        
        StatusClose = status;
        
        if StatusClose == 1
            
            display( strcat('MT4 closed the requested operation ',{' '},num2str(ticket),{' '},' at the price ',{' '},num2str(price)) );
            ms.machineStatus = 'closed';
            display(ms.machineStatus);
            
        elseif StatusClose == -1
            
            display( strcat('MT4 failed in closing the operation',{' '}, num2str(ticket)) );
            
            if trial < 5
                trial=trial+1;
                [topicPub,messagePub,startingOperation]=onlineClose002(price,ticket,indexClose);
                display( strcat('Matlab trial #',{' '},num2str(trial),{' '},' to close the operation:', {' '},num2str(ticket)) );
                display(ms.machineStatus);
                
            else
                
                receiver = '4castersltd@gmail.com';
                mail     = '4castersltd@gmail.com';
                subject  = num2str(cell2mat( strcat('MT4 failed in closing the operation',{' '}, num2str(ticket)) ));
                content  = num2str(cell2mat( strcat('Please close the operation',{' '},num2str(ticket),{' '},'manually. Matlab will consider it closed') ));
                sendgmail(receiver, subject, content, mail, password)

                display(strcat('We suppose that the operation',{' '},num2str(ticket),{' '},'has been manually closed'));
                display(ms.machineStatus);

                ms.machineStatus = 'closed';
                
            end
            
        end
        
    else
        
        display( 'problems in the received status format, please check if MT4 operated the request and proceed manually',{' '}, messageSub);
        display( 'Matlab will be resetted' )
        openValueReal = -1 ;
        startingOperation = 0;
        ms.machineStatus = 'closed';
        
    end
    
elseif listener1 && ( strcmp(ms.machineStatus,'closing') || strcmp(ms.machineStatus,'opening'))
    
    display(strcat('skipping new data point at', num2str(openingTimeScale),'min', topicSub));
    display(strcat('we are still waiting for the message of Status ...',ms.machineStatus));
    
elseif listener2 && ( strcmp(ms.machineStatus,'closing') || strcmp(ms.machineStatus,'opening'))
    
    display(strcat('skipping new data point at', num2str(closingTimeScale),'min', topicSub));
    display(strcat('we are still waiting for the message of Status ...',ms.machineStatus));
    
elseif listener3 && ( strcmp(ms.machineStatus,'closed') || strcmp(ms.machineStatus,'open'))
    
    display(strcat('WTF? Received message of Status even if the machine state is ...',ms.machineStatus, topicSub));
    
else
    
    display('WTF? Received message on unknown topic',{' '}, topicSub);
    
end


if strcmp(ms.machineStatus,'closing')
    
    tElapsedClosingRequest = toc(tStartClosingRequest);
    
    if tElapsedClosingRequest > 90
        
        display( strcat('no Status message received for closing the position',{' '}, num2str(ticket)) );
        display( strcat('We suppose that the operation',{' '},num2str(ticket),{' '},'has been closed by MT4'));
        
        receiver = '4castersltd@gmail.com';
        mail     = '4castersltd@gmail.com';
        subject  = num2str(cell2mat( strcat('no Status message received for closing the position',{' '}, num2str(ticket)) )); 
        content  = num2str(cell2mat( strcat('We suppose that the operation',{' '},num2str(ticket),{' '},'has been closed by MT4, please check if it is true') ));
        sendgmail(receiver, subject, content, mail, password)
        
        ms.machineStatus = 'closed';
        
    end
end


if ( strcmp(ms.machineStatus,'closed') || strcmp(ms.machineStatus,'open') )
    [oper, openValue, closeValue, stopLoss, takeProfit, valueTp, ~] = Algo_002_leadlag(matrix,newTimeScalePoint,openValueReal);
    
    newState{1} = oper;
    newState{2} = openValue;
    newState{3} = closeValue;
    newState{4} = stopLoss;
    newState{5} = takeProfit;
    newState{6} = valueTp;
    
    newTimeScalePoint = 0;
    updatedOperation  = newState{1};
    
end

if abs(updatedOperation) > 0 && startingOperation == 0
    % Opening request
    % ACHTUNG: The SL and TP values are sent as tenths of pips, so we have
    % to multiply by 10 to get the correct pips. I also incremented the
    % numbers to avoid Metatrader to close automatically
    MT4stopL = (stopLoss + 20) * 10;
    MT4takeP = (takeProfit + 20) * 10;
    [topicPub,messagePub,startingOperation]=onlineOpen002(oper,openValue,MT4stopL,MT4takeP,indexOpen);
    ms.machineStatus = 'opening';
    display(ms.machineStatus);
    
elseif updatedOperation == 0 && abs(startingOperation) > 0
    % Closing request
    [topicPub,messagePub,startingOperation]=onlineClose002(closeValue,ticket,indexClose);
    
    tStartClosingRequest = tic;
    
    ms.machineStatus = 'closing';
    display(ms.machineStatus);
    
end


end


