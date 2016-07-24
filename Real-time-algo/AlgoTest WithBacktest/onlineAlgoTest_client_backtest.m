function [topicPub,messagePub] = onlineAlgoTest_client_backtest(topicSub,messageSub,init)

display(strcat('Topic: ', topicSub));
display(strcat('Message: ', messageSub));
display(strcat('Init: ', init));

%r = randi([1 5])
r = 2
persistent opOpen;
if init == 1
   opOpen = 0
end
persistent opTicket;
listener1 = strcmp(topicSub,'TIMEFRAMEQUOTE@MT4@ACTIVTRADES@EURGBP@m1@v5');
listener2 = strcmp(topicSub,'STATUS@EURGBP@9999');

if listener1 == 1
    if r == 2
        %0.77224,0.77325,0.77223,0.77325,751,2016.01.21 14:00;...
        messageArr = strsplit(messageSub,';')
        messageFirstArr = strsplit(messageArr{1},',')
        topicPub = 'OPERATIONS@ACTIVTRADES@EURGBP@9999';
        if opOpen == 1
            %close position
            messagePub = sprintf('price=%s,lots=1,slippage=0.2,ticket=%s,op=0',messageFirstArr{4},opTicket );
            display(sprintf('Close Position: %s ', messagePub));
        elseif opOpen == 0
            %open position
            messagePub = sprintf('price=%s,lots=1,slippage=1.5,sl=1220,tp=1220,magic=9999,op=-1',messageFirstArr{4} )
            display(sprintf('Open Position: %s ', messagePub));
            opOpen = 2;   %waiting status message to confirm the open position
        else
            display('SKIP operation');
            topicPub = 'SKIP@ACTIVTRADES@EURGBP@9999';
            messagePub = 'SKIP';
        end
    else
        display('SKIP operation');
        topicPub = 'SKIP@ACTIVTRADES@EURGBP@9999';
        messagePub = 'SKIP';
    end
elseif listener2 == 1
    %price=0.77325,lots=1,slippage=1.5,sl=1220,tp=1220,magic=9999,op=-1
    messageArr = strsplit(messageSub,',')
    if ( (strcmp(messageArr{1},'1')==1) && (strcmp(messageArr{2},'open')==1) )
        opOpen = 1;
        opTicket = messageArr{4};
        display('Arrived status message: open position');
        display(sprintf('open: %s', messageArr{3}));
        display(sprintf('op type: %s', messageArr{2}));
        display(sprintf('op id: %s', messageArr{4}));
    elseif ( (strcmp(messageArr{1},'1')==1) && (strcmp(messageArr{2},'close')==1) )
        opOpen = 0;
        opTicket = '0';
        display('Arrived status message: close position');
        display(sprintf('close: %s', messageArr{3}));
        display(sprintf('op type: %s', messageArr{2}));
        display(sprintf('op id: %s', messageArr{4}));
    end
    display('SKIP operation');
    topicPub = 'SKIP@ACTIVTRADES@EURGBP@9999';
    messagePub = 'SKIP';
end


