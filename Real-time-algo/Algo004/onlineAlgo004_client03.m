function [topicPub,messagePub] = onlineAlgo004_client03(topicSub,messageSub,password)


% DESCRIPTION:
% -------------------------------------------------------------
% This function runs an Algo within the online trading system.
% It takes in input a topic and a relative message from the
% server. It handles the message received and send back an output
% to the server.
%
% INPUT parameters:
% -------------------------------------------------------------
% topicSub:             topic of the message received or
%                       sent. The topic acts as a key for the
%                       following message.
% messageSub:           message attached to the relative topic.
% password:             ask to the administrator
%
% OUTPUT parameters:
% -------------------------------------------------------------
% topicSub:             topic of the message to send to the
%                       server. The topic acts as a key for the
%                       following message.
% messageSub:           message sent to the server.
%
% EXAMPLE of use:
% -------------------------------------------------------------
% clear all;
% StartAlgo(IP,password);
%
% NOTE
% -------------------------------------------------------------
% please ask to the administrator the IP of the server and the
% password.
% For more details about the trading system read the documents:
% - Build AlgoV2
% - ManualeBuild AlgoV2.pdf
%


persistent matrix;
persistent newTimeScalePoint;
persistent newTimeScalePointEnd;
persistent startingOperation;
persistent numberOf1minPoints;
persistent openValueReal;
persistent trialClose;
persistent ms;
persistent tStartClosingRequest;
persistent tStartOpeningRequest;
persistent nFile
persistent logFileDimension
persistent logFile
persistent LogObj
persistent logFolderName
persistent timeSeriesProperties


nameAlgo          = 'Algo004_EURUSD';
algoTopicPub      = 'OPERATIONS@ACTIVTRADES@EURUSD@1004';
algoMagic         = 1004;
nData             = 100;
operLots          = 1;
operOpenSlippage  = 1.5;
operCloseSlippage = 0.2;
tOpenRequest      = 90;
tCloseRequest     = 90;

listener1 = strcmp(topicSub,'TIMEFRAMEQUOTE@MT4@ACTIVTRADES@EURUSD@m30@v100');
listener2 = strcmp(topicSub,'TIMEFRAMEQUOTE@MT4@ACTIVTRADES@EURUSD@m1@v1');
listener3 = strcmp(topicSub,'STATUS@EURUSD@1004');

topicPub   = '';
messagePub = '';
receiver   = '4castersltd@gmail.com';
mail       = '4castersltd@gmail.com';

closingTimeScale = 1;
openingTimeScale = 30;
server_exe = 0; % set to 1 when the Algo is running on the server as an .exe

indexOpen = 0;
indexClose = 0;

if(isempty(matrix))
    matrix = zeros(nData+1,6);
    startingOperation = 0;
    newTimeScalePoint = 0;
    numberOf1minPoints = 0;
    ms = machineStateManager;
    ms.machineStatus = 'closed';
    ms.lastOperation = 0;
    ms.openTicket = 0;
    nFile=0;
    logFileDimension=0;
    timeSeriesProperties=indicators;
end

ms.statusNotification = 0;

if(isempty (openValueReal))
    openValueReal = 0;
end

if nFile == 0
    nFile=nFile+1;
    logFolderName ='C:\Users\alericci\Desktop\Forex 4.0 noShared\test Logs\';
    if server_exe == 0 && isdir(logFolderName)
        [LogObj,logFile] = createLogFile (logFolderName,nameAlgo,nFile);
    else
        currentFolder = pwd;
        logFolderName = strcat(currentFolder,'\','logfile_',nameAlgo,'\');
        mkdir(logFolderName);
        [LogObj,logFile] = createLogFile (logFolderName,nameAlgo,nFile);
    end
elseif logFileDimension > 10000000
    nFile=nFile+1;
    fclose('all');
    [LogObj,logFile] = createLogFile (logFolderName,nameAlgo,nFile);
end

if listener1 && ( strcmp(ms.machineStatus,'closed') || strcmp(ms.machineStatus,'open') ) %new 30minutes data array
    
    LogObj.info('MATLAB info','new data array at 30min received');
    myData = strsplit(messageSub, ';');
    newTimeScalePoint = 1;
    
    for i = 1:length(myData)
        
        cells = strsplit(myData{i},',');
        matrix(i,1:5) = str2double(cells(1:5));
        matrix(i, 6) = datenum(cells{6},'mm/dd/yyyy HH:MM');
        
    end
    
    % matrix(:,end)=matrix(:,end-1); % copio l'ultima mezz ora cm se fosse il dato al minuto
    
elseif listener2 && ( strcmp(ms.machineStatus,'closed') || strcmp(ms.machineStatus,'open') ) %new 1minute data point
    
    numberOf1minPoints = numberOf1minPoints + 1 ;
    
    LogObj.info('MATLAB info','new data point at 1min received');
    newData = textscan(messageSub,'%d %d %d %d %d %s','Delimiter',','); % messageSub: open,max,min,close,volume,data
    newDataMatrix = cell2mat(newData(1:5));
    matrix(end,1)= newDataMatrix(:,1);
    matrix(end,2)= newDataMatrix(:,2);
    matrix(end,3)= newDataMatrix(:,3);
    matrix(end,4)= newDataMatrix(:,4);
    matrix(end,5)= newDataMatrix(:,5);
    matrix(end,6)=datenum(newData{6}(:),'mm/dd/yyyy HH:MM');
    
    
elseif listener3
    
    LogObj.trace('Status received',num2str(cell2mat(strcat('Topic:',{' '}, topicSub))) );
    LogObj.trace('Status received',num2str(cell2mat(strcat('Message:',{' '}, messageSub))) );
    newStatus = textscan(messageSub,'%d %s %d %d','Delimiter',','); % messageSub: status(1,-1),type(open,close),price,ticket
    status= newStatus{1};
    type= newStatus{2};
    price= newStatus{3};
    abc= newStatus{4};
    ticket = abc;
    
    LogObj.info('MATLAB info',num2str(cell2mat(strcat('STATUS received for the Ticket:',{' '}, num2str(ticket)))) );
    
     open  = strcmp(type,'open');
     close = strcmp(type,'close');
    
    ms.statusNotification = 1;
    
    if (strcmp(ms.machineStatus,'closing') || strcmp(ms.machineStatus,'opening') )%new status
        
        if open
            
            StatusOpen  = status;
            
            if StatusOpen == 1
                
                if (ticket == ms.openTicket)
                    
                    LogObj.error('MT4 info',num2str(cell2mat(strcat('We already received the status for the operation:',{' '},num2str(ms.openTicket),{' '},', it is the previous OPEN operation!'))) );
                    
                    subject  = num2str(cell2mat( strcat(nameAlgo,': We already received the status: OPEN, for this operation:',{' '}, num2str(ms.openTicket)) ));
                    content  = num2str(cell2mat( strcat('Please check on server, this is the ticket of the previous operation!') ));
                    sendgmail(receiver, subject, content, mail, password)
                    
                else
                    
                    % openValueReal = price ;
                    openValueReal = ms.lastOpenValue;
                    LogObj.info('MT4 info',num2str(cell2mat(strcat('MT4 opened the requested operation',{' '},num2str(ticket),{' '},' at the price ',{' '},num2str(price)))) );
                    ms.machineStatus = 'open';
                    ms.openTicket = ticket;
                    LogObj.trace('machine status',ms.machineStatus);
                    trialClose=1;
                    
                    pause(30) % wait the next 1 min data point
                    
                end
                
            elseif StatusOpen == -1
                
                LogObj.info('MT4 info','MT4 failed in opening the requested operation. Won t try again');
                openValueReal = -1 ;
                startingOperation = 0;
                ms.machineStatus = 'closed';
                LogObj.trace('machine status',ms.machineStatus);
                ms.statusNotification = 0;
                
            end
            
        elseif close
            
            StatusClose = status;
            
            if StatusClose == 1 && price > 0
                
                if (ticket == ms.closeTicket)
                    
                    LogObj.error('MT4 info',num2str(cell2mat(strcat('We already received the status for the operation:',{' '},num2str(ms.closeTicket),{' '},', it is the previous CLOSED operation!'))) );
                    
                    subject  = num2str(cell2mat( strcat(nameAlgo,': We already received the status: CLOSED, for this operation:',{' '}, num2str(ms.closeTicket)) ));
                    content  = num2str(cell2mat( strcat('Please check on server, this is the ticket of the previous operation!') ));
                    sendgmail(receiver, subject, content, mail, password)
                    
                elseif (ticket == ms.openTicket)
                    
                    LogObj.info('MT4 info',num2str(cell2mat(strcat('MT4 closed the requested operation ',{' '},num2str(ticket),{' '},' at the price ',{' '},num2str(price)))) );
                    ms.machineStatus = 'closed';
                    ms.closeTicket = ticket;
                    LogObj.trace('machine status',ms.machineStatus);
                    
                else
                    
                   LogObj.warn('MT4 warn',num2str(cell2mat(strcat('Matlab received a status message regarding an unknown, or an already closed, operation:',{' '}, num2str(ticket)))) );
                   LogObj.trace('machine status',ms.machineStatus);
                    
                end
                
            elseif StatusClose == -1 || price < 0
                
                if (ticket == ms.openTicket)
                    
                    if StatusClose == 1 && price < 0
                        LogObj.error( 'MT4 error',num2str(cell2mat(strcat('MT4 tried to close the requested operation',{' '}, num2str(ms.openTicket),{' '},'at the negative price',{' '},num2str(price)))) );
                    else
                        LogObj.warn('MT4 warn',num2str(cell2mat(strcat('MT4 failed in closing the operation',{' '}, num2str(ms.openTicket)))) );
                    end
                                    
                    if trialClose < 5
                        
                        trialClose=trialClose+1;
                        [topicPub,messagePub,startingOperation] = onlineClose(ms.lastCloseValue,operLots,operCloseSlippage,ms.openTicket,algoTopicPub,algoMagic,indexClose);
                        
                        LogObj.trace('problems',num2str(cell2mat(strcat('Matlab trial #',{' '},num2str(trialClose),{' '},' to close the operation:', {' '},num2str(ticms.openTicketket)))) );
                        LogObj.trace('machine status',ms.machineStatus);
                        
                    else
                        
                        LogObj.error('MT4 error',num2str(cell2mat(strcat('MT4 was not able to close the operation',{' '},num2str(ms.openTicket),{' '},'please check e-mail and close it manually'))) );
                        
                        subject  = num2str(cell2mat( strcat(nameAlgo,': MT4 failed in closing the operation',{' '}, num2str(ms.openTicket)) ));
                        content  = num2str(cell2mat( strcat('Please close the operation',{' '},num2str(ms.openTicket),{' '},'manually. Matlab will consider it closed') ));
                        sendgmail(receiver, subject, content, mail, password)
                                                
                        ms.machineStatus = 'closed';
                        LogObj.trace('machine status',ms.machineStatus);
                        
                    end
                    
                else
                    
                   LogObj.warn('MT4 warn',num2str(cell2mat(strcat('Matlab received a status message regarding an unknown, or an already closed, operation:',{' '}, num2str(ticket)))) );
                   LogObj.trace('machine status',ms.machineStatus);
                    
                end
                
            end
            
        else
            
            if (strcmp(ms.machineStatus,'opening'))
                
                if (ticket == ms.openTicket)
                    
                    LogObj.error('MT4 info',num2str(cell2mat(strcat('This stasus format is wrong and we already received the status for the operation:',{' '},num2str(ms.openTicket),{' '},', it is the previous OPEN operation!'))) );
                    
                    subject  = num2str(cell2mat( strcat(nameAlgo,': We already received the status: OPEN, for this operation:',{' '}, num2str(ms.openTicket)) ));
                    content  = strcat('The status format is wrong! Please check on server, this is the stutus of the previous OPEN operation!');
                    sendgmail(receiver, subject, content, mail, password)
                    
                else
                    
                    LogObj.warn('warn',num2str(cell2mat(strcat('This stasus format is wrong! please check if MT4 operated the opening request and proceed to close it manually',{' '}, messageSub))) );
                    LogObj.trace('MATLAB info','Matlab will be resetted' )
                    openValueReal = -1 ;
                    startingOperation = 0;
                    
                    subject  = num2str(cell2mat( strcat(nameAlgo,': problems in the received status format',{' '},messageSub)) );
                    content  = num2str(cell2mat( strcat('The status format is wrong! Please check if MT4 operated the opening request and proceed to close it manually:',{' '},num2str(ticket),{' '},'Matlab will consider it closed') ));
                    sendgmail(receiver, subject, content, mail, password)
                    
                    ms.machineStatus = 'closed';
                    LogObj.trace('machine status',ms.machineStatus);
                    ms.statusNotification = 0;
                    
                end
                
            elseif (strcmp(ms.machineStatus,'closing'))
                
                if (ticket == ms.openTicket)
                    
                    LogObj.warn('warn',num2str(cell2mat(strcat('problems in the received status format, please check if MT4 operated the closing request and proceed manually',{' '}, messageSub))) ); 
                    LogObj.trace('MATLAB info','Matlab will ignore this message and consider the operation closed' )
                    
                    subject  = num2str(cell2mat( strcat(nameAlgo,': problems in the received status format',{' '},messageSub)) );
                    content  = num2str(cell2mat( strcat('The status format is wrong! Please check if MT4 operated the closing request or proceed to close it manually:',{' '},num2str(ms.openTicket),{' '},'Matlab will consider it closed') ));
                    sendgmail(receiver, subject, content, mail, password)
                    
                    ms.machineStatus = 'closed';
                    ms.closeTicket = ticket;
                    LogObj.trace('machine status',ms.machineStatus);
                    
                else
                    
                    subject  = num2str(cell2mat( strcat(nameAlgo,': problems in the received status format',{' '},messageSub)) );
                    content  = num2str(cell2mat( strcat('The status format is wrong! Matlab received an unknown, or an already closed, operation ticket:',{' '},num2str(ms.openTicket),{' '},'Please check if MT4 operated the closing request and proceed to close it manually, Matlab will consider it closed') ));
                    sendgmail(receiver, subject, content, mail, password)
                    
                end
                
            end
            
        end
        
    elseif (strcmp(ms.machineStatus,'closed') || strcmp(ms.machineStatus,'open'))
        
        if open
            
            LogObj.warn( 'warn',num2str(cell2mat(strcat('WTF?, We Received a message of Status: OPEN at the price',{' '},num2str(price),{' '},'even if the machine state is:',{' '},ms.machineStatus,{' '},messageSub))) );
            
            subject  = num2str(cell2mat( strcat(nameAlgo,': We Received a message of Status: OPEN even if the machine state is:',{' '},ms.machineStatus)) );
            content  = num2str(cell2mat( strcat('Possible explanation: 1) This is the status of an old operation did not open because of timeout, 2) This is a copy message. The message is:',{' '},messageSub,{' '},'please check on the server')) );
            sendgmail(receiver, subject, content, mail, password)
            
        elseif close
            
            LogObj.warn( 'warn',num2str(cell2mat(strcat('WTF?, We Received a message of Status: CLOSE at the price',{' '},num2str(price),{' '},'even if the machine state is:',{' '},ms.machineStatus,{' '},messageSub))) );
            
            subject  = num2str(cell2mat( strcat(nameAlgo,': We Received a message of Status: CLOSE even if the machine state is:',{' '},ms.machineStatus',{' '},'Operation:',{' '},num2str(ticket)) ));
            content  = num2str(cell2mat( strcat('We suppose that the operation',{' '},num2str(ticket),{' '},'has been already closed, this could be a copy message.') ));
            sendgmail(receiver, subject, content, mail, password)
            
        else
            
            LogObj.warn('warn',num2str(cell2mat(strcat('problems we received an unknown status format when the machine state is ...',{' '},ms.machineStatus, messageSub))) );
            
        end
        
    end
    
elseif listener1 && ( strcmp(ms.machineStatus,'closing') || strcmp(ms.machineStatus,'opening'))
    
    LogObj.trace('MATLAB info',num2str(cell2mat(strcat('skipping data point at',{' '}, num2str(openingTimeScale),'min'))) );
    LogObj.info('MATLAB info',num2str(cell2mat(strcat('still waiting for the Status ...',{' '},ms.machineStatus))) );
    
elseif listener2 && ( strcmp(ms.machineStatus,'closing') || strcmp(ms.machineStatus,'opening'))
    
    numberOf1minPoints = numberOf1minPoints + 1 ;
    
    LogObj.trace('MATLAB info',num2str(cell2mat(strcat('skipping data point at',{' '}, num2str(closingTimeScale),'min'))) );
    LogObj.info('MATLAB info',num2str(cell2mat(strcat('still waiting for the Status ...',{' '},ms.machineStatus))) );
    
else
    
    LogObj.warn('warn',num2str(cell2mat(strcat('WTF? Received message on unknown topic',{' '}, topicSub))) );
    
end



if strcmp(ms.machineStatus,'closing')
    
    ms.tElapsedClosingRequest = toc(tStartClosingRequest);
    
    if (ms.tElapsedClosingRequest) > tCloseRequest
        
        LogObj.error('error',num2str(cell2mat(strcat('no Status message received for closing the position',{' '},num2str(ms.openTicket),{' '},'after',{' '}, num2str(ms.tElapsedClosingRequest),{' '},'seconds'))));
        LogObj.info('MATLAB info',num2str(cell2mat(strcat('We suppose that the operation',{' '},num2str(ms.openTicket),{' '},'has been closed by MT4, otherwise proceed to close it manually, please'))) );
        
        subject  = num2str(cell2mat( strcat(nameAlgo,': no Status message received for closing the position',{' '}, num2str(ms.openTicket)) ));
        content  = num2str(cell2mat( strcat('We suppose that the operation',{' '},num2str(ms.openTicket),{' '},'has been closed by MT4, otherwise proceed to close it manually, please') ));
        sendgmail(receiver, subject, content, mail, password)
        
        ms.machineStatus = 'closed';
        LogObj.trace('machine status',ms.machineStatus);
        
    end
end



if strcmp(ms.machineStatus,'opening')
    
    ms.tElapsedOpeningRequest = toc(tStartOpeningRequest);
    
    if (ms.tElapsedOpeningRequest) > tOpenRequest
        
        LogObj.error('error',num2str(cell2mat(strcat('no Status message received for opening the requested position after',{' '}, num2str(ms.tElapsedOpeningRequest),{' '},'seconds'))));
        LogObj.info('MATLAB info','We suppose that the requested operation has not been opened by MT4, otherwise proceed to close it manually, please');
        
        subject  = strcat(nameAlgo,': no Status message received for opening the requested position');
        content  = 'We suppose that the requested operation has not been opened by MT4, otherwise proceed to close it manually, please';
        sendgmail(receiver, subject, content, mail, password)
        
        LogObj.info('MATLAB info','The status of the Algo will be resetted to closed');
        openValueReal = -1 ;
        startingOperation = 0;
        ms.machineStatus = 'closed';
        LogObj.trace('machine status',ms.machineStatus);
        ms.statusNotification = 0;
        
    end
end



if numberOf1minPoints == openingTimeScale;
    newTimeScalePointEnd = 1;
    numberOf1minPoints   = 0;
else
    newTimeScalePointEnd = 0;
end

if ( ( strcmp(ms.machineStatus,'closed') || strcmp(ms.machineStatus,'open') ) && ms.statusNotification == 0 )
    t=now;
    timeMin=t*60*24;
    [oper,openValue, closeValue, stopLoss, takeProfit, minReturn] = Algo_004_statTrend(matrix,newTimeScalePoint,newTimeScalePointEnd,openValueReal,timeSeriesProperties,timeMin);
    
    %     newState{1} = oper;
    %     newState{2} = openValue;
    %     newState{3} = closeValue;
    %     newState{4} = stopLoss;
    %     newState{5} = takeProfit;
    %     newState{6} = minReturn;
    
    ms.lastOperation   = oper;
    ms.lastOpenValue   = openValue;
    ms.lastCloseValue  = closeValue;
    ms.stopLoss        = stopLoss;
    ms.takeProfit      = takeProfit;
    ms.minReturn       = minReturn;
    
    newTimeScalePoint = 0;
    
    if abs(ms.lastOperation) == 1
        LogObj.trace( 'MATLAB info', num2str(cell2mat(strcat(  'TP =',{' '},num2str(ms.takeProfit),{' '},'-',{' '},'SL =',{' '},num2str(ms.stopLoss)  ))) ) ;
    end
    
end

if abs(ms.lastOperation) > 0 && startingOperation == 0
    % Opening request
    % ACHTUNG: The SL and TP values are sent as tenths of pips, so we have
    % to multiply by 10 to get the correct pips. I also incremented the
    % numbers to avoid Metatrader to close automatically
    MT4stopL = 1000; %(stopLoss + 20) * 10;
    MT4takeP = 1500; %(takeProfit + 20) * 10;
    [topicPub,messagePub,startingOperation] = onlineOpen(ms.lastOperation,ms.lastOpenValue,operLots,operOpenSlippage,MT4stopL,MT4takeP,algoTopicPub,algoMagic,indexOpen);
    
    tStartOpeningRequest = tic;
    
    LogObj.info( 'MATLAB info', num2str(cell2mat(strcat( 'Matalb requests to open a new operation at the price',{' '},num2str(ms.lastOpenValue),{' '},'direction:',{' '},num2str(ms.lastOperation) ))) ) ;
    ms.machineStatus = 'opening';
    LogObj.trace('machine status',ms.machineStatus);
    
elseif (ms.lastOperation) == 0 && abs(startingOperation) > 0
    % Closing request
    [topicPub,messagePub,startingOperation] = onlineClose(ms.lastCloseValue,operLots,operCloseSlippage,ms.openTicket,algoTopicPub,algoMagic,indexClose);
    
    tStartClosingRequest = tic;
    
    LogObj.info( 'MATLAB info', num2str(cell2mat(strcat( 'Matalb requests to close the operation ',{' '},num2str(ms.openTicket),{' '},'at the price',{' '},num2str(ms.lastCloseValue) ))) ) ;
    ms.machineStatus = 'closing';
    LogObj.trace('machine status',ms.machineStatus);
    
end

logFileProperties=dir(logFile);
logFileDimension=logFileProperties.bytes;

clear newState
clear newStatus

% M = inmem;
% display (M);

end


