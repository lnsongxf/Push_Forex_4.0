function [topicPub,messagePub] = onlineAlgoLore(topicSub,messageSub)

%  display(strcat('Topic: ', topicSub));
%  display(strcat('Message: ', messageSub));

topicPub = '';
messagePub = '';

persistent current_value;
persistent counter;
persistent state;
persistent lastState;
persistent ticket;
persistent matrix;
persistent last_derivative;
persistent firstTime;

if isempty(counter)
    counter = 0;
    state = 0;
    lastState = -1;
    current_value = -1;
    ticket = -1;
    matrix = zeros(40, 6);
    last_derivative = 0;
    firstTime = 1;
end

listener = strcmp(topicSub,'TIMEFRAMEQUOTE@MT4@ACTIVTRADES@EURUSD@m1@v1');
listener2 = strcmp(topicSub,'TIMEFRAMEQUOTE@MT4@ACTIVTRADES@EURUSD@m1@v40');
listener3 = strcmp(topicSub,'STATUS@EURUSD@720');

if listener3 %new status
    display(strcat('Status message: ', messageSub));
    newStatus = textscan(messageSub,'%d %s %d %d','Delimiter',','); % messageSub: status(1,-1),type(open,close),price,ticket
    type= newStatus{2};
    open  = strcmp(type,'open');
    
    if open
        abc = newStatus{4};
        ticket= abc;
        display(strcat('Ticket: ', ticket));
    end
    
elseif listener2 %v40
    
    counter = counter + 1;
    display(strcat('Counter = ', num2str(counter)));
    myData = strsplit(messageSub, ';');
    
    for i = 1:length(myData)
        
        cells = strsplit(myData{i},',');
        matrix(i,1:5) = str2double(cells(1:5));
        matrix(i, 6) = datenum(cells{6},'mm/dd/yyyy HH:MM');
        
    end
    
    current_value = matrix(end, 4);
    close_vector = matrix(:,4);
    step = 0.05;
    x = 1 : 40;
    xx = 1 : step : 40;
    yy = csaps(x, close_vector, .2, xx);
    yy_ = diff(yy)/step;
    derivative = yy_(end);
    if sign(derivative) ~= sign(last_derivative)
        if abs(state) %sono in buy/sell mode
            firstTime = 1;
            lastState = state;
            state = 0;
            counter = 0;
            display('Closing existing position');
            [topicPub,messagePub,~] = onlineCloseLore(current_value,ticket,-1);
        else %sono in wait mode
            if ~firstTime
                display('Opening new position');    
                state = lastState * -1;
                [topicPub,messagePub,~] = onlineOpenLore(state,current_value,500,500,-1);
            else
                firstTime = 0;
            end
            counter = 0;
        end
        last_derivative = derivative;
    end  
    
elseif listener %v1
    
    newData = textscan(messageSub,'%d %d %d %d %d %s','Delimiter',','); % messageSub: open,max,min,close,volume,data
    newDataMatrix = cell2mat(newData(1:5));
    current_value = newDataMatrix(:,4);
end

%{
counter = counter + 1;
display(strcat('Counter = ', num2str(counter)));
if counter == 10
   counter = 0;
   if state == 0
       display('Opening new position');
       state = lastState * -1;
       [topicPub,messagePub,~] = onlineOpen(state,current_value,250,250,-1);
   else
       lastState = state;
       state = 0;
       display('Closing existing position');
       [topicPub,messagePub,~] = onlineClose(current_value,ticket,-1);
   end
   display('/-----------------------------/')
end
%}
end


