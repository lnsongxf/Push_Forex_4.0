classdef bkt_fast_009_bollinger_financialtoolbox < handle
    
    
    properties
        
        outputbkt;
        trades;
        direction;
        chei;
        r;
        openingPrices;
        OpDates;
        closingPrices;
        ClDates;
        indexClose;
        
    end
    
    
    methods
        
        function obj = fast_bollinger_financialtoolbox(obj, Pminute,P,date,newTimeScale,cost,N,nstd,plottami)
            
            % Pminute = prezzo al minuto
            % P = prezzo alla new time scale
            % date = data alla new time scale
            % cost = spread per operazione (calcolato quando chiudi)
            % N = lookback period per calcolare media e stdev
            % nstd = numero di stdev per definire le bande upper e lower (consigliato=2) 
            
            
            %% simula algo Bollinger bands usando la funzione del financial toolbox
            % (invece dell'algo 003_bollinger che implementava secondo E.Chan)
            
            pandl = zeros(size(P));
            obj.trades = zeros(size(P));
            obj.chei=zeros(size(P));
            obj.openingPrices=zeros(size(P));
            obj.closingPrices=zeros(size(P));
            obj.direction=zeros(size(P));
            obj.OpDates=zeros(size(P));
            obj.ClDates=zeros(size(P));
            obj.r =zeros(size(P));
            obj.indexClose = 0;
            
            ntrades = 0;
            s = zeros(size(P));
                      
            % mid (prezzo smooth), upper band, lower band
            [mid, uppr, lowr] = bollinger(P, N, 0, nstd);

            
            % signals
            s(P < lowr) = 1; 
            s(P > uppr) = -1;

            
            i = 101;
            
            
            while i <= length(P)
                
                % se Bollinger da il segnale, compra (-1 in short, +1 in long)
                if  abs ( s(i) ) 
                    
                    segnoOperazione = s(i);
                    ntrades = ntrades + 1;
                    [obj, Pbuy, devFluct2] = obj.apri(i, P, 0, 0, ntrades, segnoOperazione, date);
                    
                    for j = newTimeScale*(i):length(Pminute)
                        
                        indice_I = floor(j/newTimeScale);
                        
                        % cond1 è se il prezzo tocca la banda opposta
                        cond1 = s(indice_I) == -segnoOperazione;
                        % cond3 e 4 son per stop loss
                        cond3 = abs (Pminute(j) - Pbuy) >= 10;
                        cond4 = sign (Pminute(j) - Pbuy) == segnoOperazione*-1;
                        
                        if cond1
                            
                            obj.r(indice_I) = (Pminute(j) - Pbuy)*segnoOperazione - cost;
                            obj.closingPrices(ntrades) = Pminute(j);
                            obj.ClDates(ntrades) = date(indice_I); %controlla
                            %obj = obj.chiudi_per_TP(Pbuy, indice_I, segnoOperazione, devFluct2, wTP, cost, ntrades, date);
                            i = indice_I;
                            obj.indexClose = obj.indexClose + 1;
                            break
                            
                        elseif cond3 && cond4
                            
                            obj.r(indice_I) = - 10 - cost;
                            obj.closingPrices(ntrades) = Pminute(j);
                            obj.ClDates(ntrades) = date(indice_I); %controlla
                            %obj = obj.chiudi_per_SL(Pbuy, indice_I, segnoOperazione, devFluct2, wSL, cost, ntrades, date);
                            i = indice_I;
                            obj.indexClose = obj.indexClose + 1;
                            break
                            
                        end
                        
                        i = indice_I;
                        obj.trades(i) = 1;
                        
                    end
                    
               
                end
                
                i = i + 1;
                
            end
            
            %             pandl = cumsum(r);
            %             sh = pandl(end);
            %
            %
            %             cumprof= cumsum(r(r~=0))*10;
            %             profittofinale = sum(r);
            %
            
            obj.outputbkt(:,1) = obj.chei(1:obj.indexClose);                    % index of stick
            obj.outputbkt(:,2) = obj.openingPrices(1:obj.indexClose);      % opening price
            obj.outputbkt(:,3) = obj.closingPrices(1:obj.indexClose);        % closing price
            obj.outputbkt(:,4) = (obj.closingPrices(1:obj.indexClose) - ...
                obj.openingPrices(1:obj.indexClose)).*obj.direction(1:obj.indexClose);   % returns
            obj.outputbkt(:,5) = obj.direction(1:obj.indexClose);              % direction
            obj.outputbkt(:,6) = ones(obj.indexClose,1);                    % real
            obj.outputbkt(:,7) = obj.OpDates(1:obj.indexClose);              % opening date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
            obj.outputbkt(:,8) = obj.ClDates(1:obj.indexClose);                % closing date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
            obj.outputbkt(:,9) = ones(obj.indexClose,1)*1;                 % lots setted for single operation
            
            
            
            % Plot a richiesta
            if plottami
                
                figure
                ax(1) = subplot(2,1,1);
                plot(P), grid on
                hold on
                plot(mid,'black')
                plot(uppr, 'red')
                plot(lowr,'red')
                legend('Price','mid','upper','lower')
                title(['Bollinger con lookperiod ',num2str(N)])
                ax(2) = subplot(2,1,2);
                plot(cumsum(obj.outputbkt(:,4))), grid on
                legend('Cumulative Return')
                title('Cumulative Returns ')
                %linkaxes(ax,'x')
                
            end %if
            
        end
        
        
        function [obj, Pbuy, devFluct2] = apri(obj, i, P, ~, ~, ntrades, segnoOperazione, date)
            
            obj.trades(i) = 1;
            Pbuy = P(i);
            devFluct2 = 1; % lo impongo sempre uguale a 1
            %devFluct2 = std(fluctuationslag((i-(100-M)):i));
            obj.direction(ntrades)= segnoOperazione;
            obj.chei(ntrades)=i;
            obj.openingPrices(ntrades) = Pbuy;
            obj.OpDates(ntrades) = date(i);
            
        end
        
        
        
%         function [obj] = chiudi_per_SL(obj, Pbuy, indice_I, segnoOperazione, devFluct2, wSL, cost, ntrades, date)
%             
%             obj.r(indice_I) = - wSL*devFluct2 - cost;
%             obj.closingPrices(ntrades) = Pbuy - segnoOperazione*floor(wSL*devFluct2);
%             obj.ClDates(ntrades) = date(indice_I); %controlla
%             
%         end
%         
%         function [obj] = chiudi_per_TP(obj, Pbuy, indice_I, segnoOperazione, devFluct2, wTP, cost, ntrades, date)
%             
%             obj.r(indice_I) = wTP*devFluct2 - cost;
%             obj.closingPrices(ntrades) = Pbuy + segnoOperazione*floor(wTP*devFluct2);
%             obj.ClDates(ntrades) = date(indice_I); %controlla
%             
%         end



function sd=movingStd(x, T)
    % calculate standard deviation of x over T days. Expect T-1
    % NaN in the beginning of the series
    % It creates moving std of lookback
    % periods. I.e. data is sampled every period.
    % This uses std which normalizes by N-1.
    
    sd=NaN*ones(size(x));
    
    for t=T:size(x, 1)
        
        sd(t, :)=std(x(t-T+1:t, :));
        
    end
     
end
    


    end

end


