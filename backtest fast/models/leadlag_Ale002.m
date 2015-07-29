function outputmio = leadlag_Ale002(P,date,N,M,cost)


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
i = 101;

while i <= length(P)
    
    
    % se il trend breve va sotto quello lungo compra long
    if ( s(i) < s(i-1) ) && s(i) == -1
        
        trades(i) = 1;
        Pbuy = P(i);
        devFluct2 = floor(std(fluctuationslag((i-100+M):i)));
        ntrades = ntrades + 1;
        direction(ntrades)=1;
        chei(ntrades)=i;
        openingPrices(ntrades) = Pbuy;
        OpDates(ntrades) = date(i);
        
        for j = i+1:length(P)
            
            %devFluct2 = std(fluctuationslag((j-M):j));
            %devFluct2 = std(lag((j-100):j));
            standev(j) = devFluct2;
            
            if P(j) >= (Pbuy + 5*devFluct2)
                
                %r(j) =  P(j)-Pbuy-cost;
                r(j) = 5*devFluct2 - cost;
                closingPrices(ntrades) = P(j);
                ClDates(ntrades) = date(j);
                i = j;
                trades(i) = 0;
                break
                
            elseif P(j) <=  (Pbuy - devFluct2)
                
                %r(j) =  P(j)-Pbuy-cost;
                r(j) =  - devFluct2 - cost;
                closingPrices(ntrades) = P(j);
                ClDates(ntrades) = date(j);
                i = j;
                trades(i) = 0;
                break
                
            end
            
            i = j;
            trades(i) = 1;
            
        end
        
        % se il trend breve va sopra quello lungo compra short
    elseif ( s(i) > s(i-1) ) && s(i) == 1
        
        trades(i) = -1;
        Pbuy = P(i);
        devFluct2 = floor(std(fluctuationslag((i-100+M):i)));
        ntrades = ntrades + 1;
        direction(ntrades)=-1;
        chei(ntrades)=i;
        openingPrices(ntrades) = Pbuy;
        OpDates(ntrades) = date(i);
        
        for j = i+1:length(P)
            
            %devFluct2 = std(fluctuationslag((j-M):j));
            %devFluct2 = std(lag((j-100):j));
            standev(j) = devFluct2;
            
            if P(j) <= (Pbuy - 5*devFluct2)
                
                %r(j) =  -(P(j)-Pbuy) - cost;
                r(j) = 5*devFluct2 - cost;
                closingPrices(ntrades) = P(j);
                ClDates(ntrades) = date(j);
                i = j;
                trades(i) = 0;
                break
                
            elseif P(j) >=  (Pbuy + devFluct2)
                
                %r(j) =  -(P(j)-Pbuy) - cost;
                r(j) = - devFluct2 - cost;
                closingPrices(ntrades) = P(j);
                ClDates(ntrades) = date(j);
                i = j;
                trades(i) = 0;
                break
                
            end
            
            i = j;
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
    title(['Final Return = ',num2str(sum(r),3),' (',num2str(sum(r)/P(1)*100,3),'%)'])
    xlabel(ax(1), 'Serial day number');
    xlabel(ax(2), 'Serial day number');
    ylabel(ax(1), 'Price ($)');
    ylabel(ax(2), 'Returns ($)');
    linkaxes(ax,'x')

end %if