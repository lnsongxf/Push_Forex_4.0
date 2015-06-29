function [outputBktOffline]=bktOffline(nData,histName)
% Commenti al codice sono contrassegnati da by_ivan
% In generale e' molto ben fatto e non vedo errori particolari.
% Per ora non ho matlab e' non posso fare il debug, aspetto Simone che crei la macchina virtuale,
% ma se gia' facessi il push del dummy storico e del'algo di test, potrei darti un'idea piu' precisa.
% Se lo hai gia' fatto, non sono riuscito a trovare i file.
%
% DESCRIPTION:
% -------------------------------------------------------------
% This function runs the offline backtest on given historical data
%
%
% INPUT parameters:
% -------------------------------------------------------------
% nData             ...
% histName          ... 'storico.csv'
%                   ...
%                   ...
%
% OUTPUT parameters:
% -------------------------------------------------------------
%
%
%
% EXAMPLE of use:
% -------------------------------------------------------------
%
%


storico = csvread(histName);
startingOperation=0;
indexResult=0;

ls=length(storico);

for i=nData:ls
    
    [oper, openValue, closeValue, stopLoss, noLoose, valueTp] = Algo_testBktOffline(storico(i-(nData-1):i,:));
% newState=Algo_testBktOffline(storico(i-(nData-1):i,:));
      
        newState{1}=oper;
        newState{2}=openValue;
        newState{3}=closeValue;
        newState{4}=stopLoss;
        newState{5}=noLoose;
        newState{6}=valueTp;

        updatedOperation=newState{1};
        
        if abs(updatedOperation)>0 && startingOperation==0
            indexResult=indexResult+1;
            startingOperation=newState{1};
            
            display(indexResult);
            display(startingOperation);
            
            direction(indexResult)=newState{1};
            openingPrice(indexResult)=newState{2};
            
        elseif updatedOperation==0 && abs(startingOperation)>0
            closingPrice(indexResult)=newState{3};   
            display(closeValue);
            startingOperation=0;
            display('operation closed');
        end

end

if length(direction)>length(closingPrice)
    l=length(direction)-1;
else
    l=length(direction);
end
outputBktOffline=zeros(l,8);

% outputBktOffline(:,1)=nCandelotto;           % index of stick
outputBktOffline(:,2)=openingPrice(1:l);          % opening price
outputBktOffline(:,3)=closingPrice(1:l);          % closing price
% outputBktOffline(:,4)=matrixWeb(:,4);        % returns
outputBktOffline(:,5)=direction(1:l);             % direction
outputBktOffline(:,6)=ones(l,1);              % real
% outputBktOffline(:,7)=openingDateNum;        % opening date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
% outputBktOffline(:,8)=closingDateNum;        % closing date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')


