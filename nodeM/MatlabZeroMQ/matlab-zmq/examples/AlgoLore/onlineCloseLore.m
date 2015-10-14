function [topicPub,messagePub,startingOperation]=onlineCloseLore(closeValue,ticket,indexClose)

%closing
% example: op=0, price=135, lot=1, slippage=02, ticket= 12345op=strcat('op=',num2str(0));
op = 'op=0';
price=strcat('price=',num2str(closeValue));
lots=strcat('lots=',num2str(1));                                           % for the moment we consider always lot=1
slippage=strcat('slippage=',num2str(0.2));                                 % for the opening slippage=1.5 pips
ticket=strcat('ticket=',num2str(ticket));                                  % ticket logic still to implement
topicPub='OPERATIONS@ACTIVTRADES@EURUSD@720';
messagePub=strcat(price,',',lots,',',slippage,',',ticket,',',op);

indexClose = indexClose + 1;
display(strcat('indexClose =', num2str(indexClose)));
display(strcat('closeValue =', num2str(closeValue)));

display(strcat('Matalb requests to close the operation ',num2str(ticket)) ) ;

startingOperation = 0;

end