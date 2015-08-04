function [outputmio,iOpen,iClose,jClose,standev,s,lead,lag] = leadlag_doppiatimescale_Ale002(Pminute,P,date,N,M,newTimeScale,cost)


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
  
        display(['ntrade = ' num2str(ntrades+1)]);
        display(['opening i = ' num2str(i+1)]);
        trades(i) = 1;
        Pbuy = P(i);
        display(['opening price = ' num2str(Pbuy)]);
        devFluct2 = std(fluctuationslag((i-(100-M)):(i-1)));
        display(['SL = ', num2str(floor(devFluct2)),' TP =', num2str(floor(5*devFluct2))]);
        ntrades = ntrades + 1;
        direction(ntrades)=1;
        chei(ntrades)=i;
        openingPrices(ntrades) = Pbuy;
        OpDates(ntrades) = date(i);
        
        for j = newTimeScale*(i)+1:length(Pminute)
            
            indice_I = floor(j/newTimeScale);
            
            standev(indice_I) = devFluct2;
            
            if Pminute(j) >= (Pbuy + floor(5*devFluct2))
                
                %r(j) =  P(j)-Pbuy-cost;
                r(indice_I) = 5*devFluct2 - cost;
                closingPrices(ntrades) = Pbuy + floor(5*devFluct2);
                display(['closing price= ' num2str(closingPrices(ntrades))]);
                %closingPrices(ntrades) = Pminute(j);
                ClDates(ntrades) = date(indice_I); %controlla
                iClose(ntrades) = indice_I;
                jClose(ntrades) = j;
                i = indice_I;
                display(['closing i = ' num2str(i)]);
                break
                
            elseif Pminute(j) <=  (Pbuy - floor(devFluct2))
                
                %r(j) =  P(j)-Pbuy-cost;
                r(indice_I) =  - devFluct2 - cost;
                closingPrices(ntrades) = Pbuy - floor(devFluct2);
                display(['closing price= ' num2str(closingPrices(ntrades))]);
                %closingPrices(ntrades) = Pminute(j);
                ClDates(ntrades) = date(indice_I);
                iClose(ntrades) = indice_I;
                jClose(ntrades) = j;
                i = indice_I;
                display(['closing i = ' num2str(i)]);
                break
                
            end
            
            i = indice_I;
            trades(i) = 1;
            
        end
        
    % se il trend breve va sopra quello lungo compra short
    elseif ( s(i) - s(i-1) == 2)
        
        display(['ntrade = ' num2str(ntrades+1)]);
        display(['opening i = ' num2str(i+1)]);
        trades(i) = -1;
        Pbuy = P(i);
        display(['opening price = ' num2str(Pbuy)]);
        devFluct2 = std(fluctuationslag((i-(100-M)):(i-1)));
        display(['SL = ', num2str(floor(devFluct2)),' TP =', num2str(floor(5*devFluct2))]);
        ntrades = ntrades + 1;
        direction(ntrades)=-1;
        chei(ntrades)=i;
        openingPrices(ntrades) = Pbuy;
        OpDates(ntrades) = date(i);
        
        for j = newTimeScale*(i)+1:length(Pminute)
            
            indice_I = floor(j/newTimeScale);
            
            standev(indice_I) = devFluct2;
            
            if Pminute(j) <= (Pbuy - floor(5*devFluct2))
                
                %r(j) =  -(P(j)-Pbuy) - cost;
                r(indice_I) = 5*devFluct2 - cost;
                closingPrices(ntrades) = Pbuy - floor(5*devFluct2);
                display(['closing price= ' num2str(closingPrices(ntrades))]);
                %closingPrices(ntrades) = Pminute(j);
                ClDates(ntrades) = date(indice_I); %controlla
                iClose(ntrades) = indice_I;
                jClose(ntrades) = j;
                i = indice_I;
                display(['closing i = ' num2str(i)]);
                break
                
            elseif Pminute(j) >=  (Pbuy + floor(devFluct2))
                
                %r(j) =  -(P(j)-Pbuy) - cost;
                r(indice_I) = - devFluct2 - cost;
                closingPrices(ntrades) = Pbuy + floor(devFluct2);
                display(['closing price= ' num2str(closingPrices(ntrades))]);
                %closingPrices(ntrades) = Pminute(j);
                ClDates(ntrades) = date(indice_I); %controlla
                iClose(ntrades) = indice_I;
                jClose(ntrades) = j;
                i = indice_I;
                display(['closing i = ' num2str(i)]);
                break
                
            end
            
            i = indice_I;
            trades(i) = -1;
            
        end
        
    end
    
    i = i + 1;
    
end

% sh = scaling*sharpe(r,0);
pandl = cumsum(r);
sh = pandl(end);


cumprof= cumsum(r(r~=0))*10;
profittofinale = sum(r);

outputmio(:,1) = chei(1:ntrades);       % index of stick
outputmio(:,2) = openingPrices(1:ntrades);      % opening price
outputmio(:,3) = closingPrices(1:ntrades);        % closing price
outputmio(:,4) = (closingPrices(1:ntrades) - openingPrices(1:ntrades)).*direction(1:ntrades);                % returns
outputmio(:,5) = direction(1:ntrades);             % direction
outputmio(:,6) = ones(ntrades,1);                  % real
outputmio(:,7) = OpDates(1:ntrades);      % opening date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
outputmio(:,8) = ClDates(1:ntrades);        % closing date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
outputmio(:,9) = ones(ntrades,1)*1;                           % lots setted for single operation


iOpen=chei(1:ntrades);
iClose=iClose(1:ntrades);
jClose=jClose(1:ntrades);


if nargout == 0 % Plot
    
    
    
    
    %display(ntrades);
    
    % Plot results
    
    %    figure
    %    plot(trades);
    %figure
    %plot(cumprof);
    %figure
    %plot(r(r~=0));
    %    figure
    %    plot([(lag+standev),(lag-standev)]);
    % figure
    %plot(standev);
    %  figure
    %  plot(chei);
    
    figure
    ax(1) = subplot(2,1,1);
    plot([P(M:end),lead(M:end),lag(M:end)],'LineWidth',1); grid on
    legend('Close',['Lead ',num2str(N)],['Lag ',num2str(M)],'Location','Best')
    title(['Lead/Lag EMA Results, Annual Fake Sharpe Ratio = ',num2str(sh,3)])
    ax(2) = subplot(2,1,2);
    plot([trades,pandl*10,standev],'LineWidth',1); grid on
    legend('Position','Returns','standev','Location','Best')
    title(['NumTrades = ',num2str(ntrades),', Final Return = ',num2str(sum(r),3),' (',num2str(sum(r)/P(1)*100,3),'%)'])
    xlabel(ax(1), 'Serial day number');
    xlabel(ax(2), 'Serial day number');
    ylabel(ax(1), 'Price ($)');
    ylabel(ax(2), 'Returns ($)');
    linkaxes(ax,'x')

end %if