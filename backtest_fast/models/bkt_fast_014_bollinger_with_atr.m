classdef bkt_fast_014_bollinger_with_atr < handle
    
    
    properties
        
        outputbkt;
        trades;
        direction;
        chei;
        r;
        openingPrices;
        OpDates;
        indexOpen;
        closingPrices;
        ClDates;
        indexClose;
        latency;
        
    end
    
    
    methods
        
        function obj = spin(obj, ~, matrixNewHisData, ~, ~, N, nstd, cost, ~, ~, ~, ~, plottami)
            
            % Pminute = prezzo al minuto
            % P = prezzo alla new time scale
            % date = data alla new time scale
            % cost = spread per operazione (calcolato quando chiudi)
            % N = lookback period per calcolare media e stdev
            % nstd = numero di stdev per definire le bande upper e lower (consigliato=2)
            
            
            %% simula algo Bollinger bands usando la funzione del financial toolbox
            % (invece dell'algo 003_bollinger che implementava secondo E.Chan)
            
            hi = matrixNewHisData(:,2);
            lo = matrixNewHisData(:,3);
            P = matrixNewHisData(:,4);
            date = matrixNewHisData(:,6);
            
            %pandl = zeros(size(P));
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
            [mid, uppr, lowr] = bollinger(P, N, 2, nstd);
            
            
            % signals
            s(P < mid) = -1;
            s(P > mid) = 1;
            
            % calculate the average true range (used to set TP e SL)
            atr = tech_indicators( [hi,lo,P] , 'atr' , 20);
            
            
            i = 101;
            
            
            while i <= length(P)
                
                % se il prezzo incrocia la middle band di Bollinger, parte l'operazione
                if   ( s(i)*s(i-1) < 0 )
                    
                    segnoOperazione = s(i);
                    ntrades = ntrades + 1;
                    [obj, Pbuy, ~] = obj.apri(i, P, 0, 0, ntrades, segnoOperazione, date);
                    
                    TakeP = min(floor(atr(i)),10);
                    StopL = min(floor(atr(i)),10);
                    TakeProfitPrice = Pbuy + segnoOperazione * TakeP;
                    StopLossPrice =  Pbuy - segnoOperazione * StopL;
%                     
%                     display(['Pbuy =' num2str(Pbuy)]);
%                     display(['segnoOperazione =' num2str(segnoOperazione)]);
%                     display(['TakeProfitPrice =' num2str(TakeProfitPrice)]);
%                     display(['StopLossPrice =' num2str(StopLossPrice)]);
%                     
                    for j = i+1 : length(P)
                        %%%%%%%%%%% dynamicalTPandSL using atr
                        
                        if ( sign( P(j) - P(j-1) ) == segnoOperazione )
                            if (  sign( P(j) + segnoOperazione *floor(atr(j)) - TakeProfitPrice ) == segnoOperazione )
                                TakeProfitPrice = P(j) + segnoOperazione *floor(atr(j));
                            end
                            if (  sign( P(j) - segnoOperazione *floor(atr(j)) - StopLossPrice ) == segnoOperazione )
                                StopLossPrice = P(j) - segnoOperazione *floor(atr(j));
                            end
%                             display(['TakeProfitPrice =' num2str(TakeProfitPrice)]);
%                             display(['StopLossPrice =' num2str(StopLossPrice)]);
                        end
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        condTP = ( sign( P(j) - TakeProfitPrice ) * segnoOperazione );
                        condSL = ( sign( StopLossPrice - P(j) ) ) * segnoOperazione;
                        
                        if ( condTP >=0 ) || ( condSL >= 0 )
                            
                            obj.r(j) = (P(j) - Pbuy)*segnoOperazione - cost;
                            obj.closingPrices(ntrades) = P(j);
                            obj.ClDates(ntrades) = date(j); %controlla
                            obj.chei(ntrades)=j;
                            obj.indexClose = obj.indexClose + 1;
                            obj.latency(ntrades)=j - obj.indexOpen;
%                             display( '---------------------' );
                            break
                            
                        end
                        
                        
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
            obj.outputbkt(:,10) = obj.latency(1:obj.indexClose);        % number of minutes the operation was open
            obj.outputbkt(:,11) = ones(obj.indexClose,1);         % to be done     % minimum return touched during dingle operation
            
            
            
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
            obj.openingPrices(ntrades) = Pbuy;
            obj.OpDates(ntrades) = date(i);
            obj.indexOpen = i;
            
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


