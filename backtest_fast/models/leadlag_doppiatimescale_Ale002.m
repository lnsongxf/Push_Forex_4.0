function [sh,outputmio] = leadlag_doppiatimescale_Ale002(Pminute,P,date,N,M,newTimeScale,cost,wSL,wTP)


%% simula algo Ale002

s = zeros(size(P));

a = (1/N)*ones(1,N);
lead = filter(a,1,P);

b = (1/M)*ones(1,M);
lag = filter(b,1,P);
fluctuationslag=abs(P-lag);

s(lead>lag) = 1; % signals
s(lag>lead) = -1;

pandl = zeros(size(P));
r =zeros(size(P));
trades = zeros(size(P));
standev = zeros(size(P));
ntrades = 0;
indexClose = 0;
chei=zeros(size(P));
openingPrices=zeros(size(P));
closingPrices=zeros(size(P));
direction=zeros(size(P));
OpDates=zeros(size(P));
ClDates=zeros(size(P));
iOpen=zeros(size(P));
iClose=zeros(size(P));
jClose=zeros(size(P));

i = 101;


while i <= length(P)
    
    % se il trend breve va sotto quello lungo compra long
    if ( s(i) - s(i-1) == -2 )
  
        trades(i) = 1;
        Pbuy = P(i);
        devFluct2 = std(fluctuationslag((i-(100-M)):i));
        ntrades = ntrades + 1;
        direction(ntrades)=1;
        chei(ntrades)=i;
        openingPrices(ntrades) = Pbuy;
        OpDates(ntrades) = date(i);
        
        for j = newTimeScale*(i):length(Pminute)
            
            indice_I = floor(j/newTimeScale);
            
            standev(indice_I) = devFluct2;
            
            if Pminute(j) >= (Pbuy + floor(wTP*devFluct2))
                
                r(indice_I) = wTP*devFluct2 - cost;
                closingPrices(ntrades) = Pbuy + floor(wTP*devFluct2);
                ClDates(ntrades) = date(indice_I); %controlla
                iClose(ntrades) = indice_I;
                jClose(ntrades) = j;
                indexClose = indexClose + 1;
                i = indice_I;
                break
                
            elseif Pminute(j) <=  (Pbuy - floor(wSL*devFluct2))
                
                r(indice_I) =  - wSL*devFluct2 - cost;
                closingPrices(ntrades) = Pbuy - floor(wSL*devFluct2);
                ClDates(ntrades) = date(indice_I);
                iClose(ntrades) = indice_I;
                jClose(ntrades) = j;
                indexClose = indexClose + 1;
                i = indice_I;
                break
                
            end
            
            i = indice_I;
            trades(i) = 1;
            
        end
        
    % se il trend breve va sopra quello lungo compra short
    elseif ( s(i) - s(i-1) == 2)
        
        trades(i) = -1;
        Pbuy = P(i);
        devFluct2 = std(fluctuationslag((i-(100-M)):i));
        ntrades = ntrades + 1;
        direction(ntrades)=-1;
        chei(ntrades)=i;
        openingPrices(ntrades) = Pbuy;
        OpDates(ntrades) = date(i);
        
        for j = newTimeScale*(i):length(Pminute)
            
            indice_I = floor(j/newTimeScale);
            
            standev(indice_I) = devFluct2;
            
            if Pminute(j) <= (Pbuy - floor(wTP*devFluct2))
                
                r(indice_I) = wTP*devFluct2 - cost;
                closingPrices(ntrades) = Pbuy - floor(wTP*devFluct2);
                ClDates(ntrades) = date(indice_I); %controlla
                iClose(ntrades) = indice_I;
                jClose(ntrades) = j;
                indexClose = indexClose + 1;
                i = indice_I;
                break
                
            elseif Pminute(j) >=  (Pbuy + floor(wSL*devFluct2))
                
                r(indice_I) = - wSL*devFluct2 - cost;
                closingPrices(ntrades) = Pbuy + floor(wSL*devFluct2);
                ClDates(ntrades) = date(indice_I); %controlla
                iClose(ntrades) = indice_I;
                jClose(ntrades) = j;
                indexClose = indexClose + 1;
                i = indice_I;
                break
                
            end
            
            i = indice_I;
            trades(i) = -1;
            
        end
        
    end
    
    i = i + 1;
    
end

pandl = cumsum(r);
sh = pandl(end);


cumprof= cumsum(r(r~=0))*10;
profittofinale = sum(r);


outputmio(:,1) = chei(1:indexClose);                    % index of stick
outputmio(:,2) = openingPrices(1:indexClose);      % opening price
outputmio(:,3) = closingPrices(1:indexClose);        % closing price
outputmio(:,4) = (closingPrices(1:indexClose) - ...
    openingPrices(1:indexClose)).*direction(1:indexClose);   % returns
outputmio(:,5) = direction(1:indexClose);              % direction
outputmio(:,6) = ones(indexClose,1);                    % real
outputmio(:,7) = OpDates(1:indexClose);              % opening date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
outputmio(:,8) = ClDates(1:indexClose);                % closing date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
outputmio(:,9) = ones(indexClose,1)*1;                 % lots setted for single operation


iOpen=chei(1:indexClose);
iClose=iClose(1:indexClose);
jClose=jClose(1:indexClose);


% Plot se la funzione viene chiamata senza argomenti in output
if nargout == 0 
    
    figure
    ax(1) = subplot(2,1,1);
    plot([P(M:end),lead(M:end),lag(M:end)],'LineWidth',1); grid on
    legend('Close',['Lead ',num2str(N)],['Lag ',num2str(M)],'Location','Best')
    title(['Lead/Lag EMA Results, Final Return = ',num2str(sh,3)])
    ax(2) = subplot(2,1,2);
    plot([trades,pandl*10,standev],'LineWidth',1); grid on
    legend('Position','Returns','standev','Location','Best')
    title(['NumTrades = ',num2str(indexClose),', Final Return = ',num2str(sum(r),3),' (',num2str(sum(r)/P(1)*100,3),'%)'])
    xlabel(ax(1), 'Serial index i number');
    xlabel(ax(2), 'Serial index i number');
    ylabel(ax(1), 'Price ($)');
    ylabel(ax(2), 'Returns ($)');
    linkaxes(ax,'x')

end %if