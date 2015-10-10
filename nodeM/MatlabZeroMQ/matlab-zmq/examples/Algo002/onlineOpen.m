function [topicPub,messagePub,startingOperation]=onlineOpen(oper,openValue,stopLoss,takeProfit,indexOpen)

%opening
% in sell con take profit e stop loss settati: op=-1, price=132, lot=1, slippage=05, sl=122, tp=142
% in buy senza take profit e stop loss settati: op=1, price=132, lot=1, slippage=05op=strcat('op=',num2str(open));

op=strcat('op=',num2str(oper));
price=strcat('price=',num2str(openValue));
lots=strcat('lots=',num2str(1));                                           % for the moment we consider always lot=1
slippage=strcat('slippage=',num2str(1.5));                                 % for the opening slippage=1.5 pips
sl=strcat('sl=',num2str(stopLoss));                                        % not madatory
tp=strcat('tp=',num2str(takeProfit));                                      % not mandatory
topicPub='MATLAB@111@EURUSD@OPERATIONS';
messagePub=strcat(op,',',price,',',lots,',',slippage,',',sl,',',tp);

indexOpen = indexOpen + 1;
display(['indexOpen =' num2str(indexOpen)]);
display(['direction =' num2str(oper)]);

text=strcat('Matalb requests to open a new operation');
display (text);

startingOperation = oper;

end