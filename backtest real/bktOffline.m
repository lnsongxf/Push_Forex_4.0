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

for i=nData:length(storico)
    
    newState = Algo_testBktOffline(storico(i-(nData-1):i,:));
    
    %risultato contiene [oper, openValue, closeValue, stopLoss, noLoose, valueTp, real]
    
    if newState %by_ivan si assume che se l'algo non prende decisioni, il vettore newState e' vuoto?
	            %puoi anche usare isempty(variabile)
		updatedOperation=newState{1};
    
		if abs(updatedOperation)>1 && startingOperation==0
        
			indexResult=indexResult+1;
			startingOperation=newState{1};
        
			direction(indexResult)=newState{1};
			openingPrice(indexResult)=newState{2};
			realoper(indexResult)=newState{7};
        
		elseif updatedOperation==0 && abs(startingOperation)>0
			closingPrice(indexResult)=newState{3};
		end
    end
end
l=length(openingPrice);
outputBktOffline=zeros(l,8);

% outputBktOffline(:,1)=nCandelotto;           % index of stick
outputBktOffline(:,2)=openingPrice;          % opening price
outputBktOffline(:,3)=closingPrice;          % closing price
% outputBktOffline(:,4)=matrixWeb(:,4);        % returns
outputBktOffline(:,5)=direction;             % direction
outputBktOffline(:,6)=realoper;              % real
% outputBktOffline(:,7)=openingDateNum;        % opening date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
% outputBktOffline(:,8)=closingDateNum;        % closing date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')

%by_ivan puo' essere che l'ultima operazione non venga chiusa prima della fine del backtest, per questo 
%dovresti escludere l'ultima riga di output nel case closingPrice(length(closingPrice)) == 0

%
% for i = 100:(length(v)-120)
%    v1 = v(i-99:i,1) ;
%    v2 = v(i-99:i,2) ;
%    v3 = v(i-99:i,3) ;
%    v4 = v(i-99:i,4) ;
%    %v5 = v(i-99:i,5) ;
%    v5 = [4 5 6];
%    for j = (i-1)*60+1:i*60
%         value = vp(j,4);
%         maxValue = vp(j,2);
%         minValue = vp(j,3);
%         v4(end) = value;
%         memory = operation;
%         %v4Minuto = vp(j-7999:j,4);
%         %v2Minuto = vp(j-7999:j,2);
%         %v3Minuto = vp(j-7999:j,3);
%         lifeCicleNew(v1,v2,v3,v4,v5);
%         if(sign(memory) > sign(operation) || sign(memory) < sign(operation))
%             k = k+1;
%             operazioni(k,2) = value;
%             operazioni(k,1) = operation;
%         end
%    end


% risultato e' un array che contiene diversi valori
% [17:49:48] Ivan Valeriani: tipo apertura, chiusura, direzione...

