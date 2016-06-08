function [topicPub,messagePub,startingOperation]=onlineClose(closeValue,operLots,operCloseSlippage,ticket,algoTopicPub,algoMagic,indexClose)

%closing
% example: op=0, price=135, lot=1, slippage=02, ticket= 12345op=strcat('op=',num2str(0));
op = 'op=0';
price=strcat('price=',num2str(closeValue));
lots=strcat('lots=',num2str(operLots));                                    % for the moment we consider always lot=1
slippage=strcat('slippage=',num2str(operCloseSlippage));                   % for the opening slippage=1.5 pips
ticket=strcat('ticket=',num2str(ticket));                                  % ticket logic still to implement
topicPub=algoTopicPub;                                                     % for example: 'OPERATIONS@ACTIVTRADES@AUDCAD@9999'
magic=strcat('magic=',num2str(algoMagic));                                 % magic number, algo id.
messagePub=strcat(price,',',lots,',',slippage,',',ticket,',',op,',',magic);

indexClose = indexClose + 1;
display(strcat('indexClose =', num2str(indexClose)));
display(strcat('closeValue =', num2str(closeValue)));

startingOperation = 0;

end