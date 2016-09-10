classdef bkt_fast_008b_inverted_supertrend < handle
    
    % bktfast VERSION 3 (with arrayAperture and minimumReturns)
    
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
        arrayAperture;
        minimumReturns;
        
    end
    
    
    methods
        
        function obj = spin(obj, ~, matrixNewHisData, ~, ~, N, M, cost, ~, ~, ~, ~, plottami) 
            
            % Pminute = prezzo al minuto
            % matrixNewHisData = matrice con prezzi e date alla new time scale
            % N = lunghezza storico segnale maxhigh-maxLow
            % M = lunghezza storico per average price (M<N)
            % cost = spread per operazione (calcolato quando chiudi)
            % wSL = peso per calcolare quando chiuder per SL
            % wTP = peso per calcolare quando chiuder per TP
            
            %% utilizza segnale del supertrend sia in apertura che in chiusura
                        
            high = matrixNewHisData(:,2);
            low = matrixNewHisData(:,3);
            P = matrixNewHisData(:,4);
            date = matrixNewHisData(:,6);
            
            sizeStorico = size(matrixNewHisData,1);
            
            pandl = zeros(sizeStorico,1);
            obj.trades = zeros(sizeStorico,1);
            obj.chei=zeros(sizeStorico,1);
            obj.openingPrices=zeros(sizeStorico,1);
            obj.closingPrices=zeros(sizeStorico,1);
            obj.direction=zeros(sizeStorico,1);
            obj.OpDates=zeros(sizeStorico,1);
            obj.ClDates=zeros(sizeStorico,1);
            obj.r =zeros(sizeStorico,1);
            obj.latency= zeros(sizeStorico,1);
            obj.arrayAperture= zeros(sizeStorico,1);
            obj.minimumReturns = zeros(sizeStorico,1);
            
            ntrades = 0;
            obj.indexClose = 0;
            s = zeros(sizeStorico,1);
            hl = zeros(sizeStorico,1);
            
            atr= zeros(sizeStorico,1);
            avg= zeros(sizeStorico,1);
            
            for k = N:(sizeStorico)
                
                hl = high(k-N+1:k) - low(k-N+1:k);
                atr(k) = mean(hl);
                avg(k) = ( mean(high(k-M+1:k)) + mean(low(k-M+1:k)) ) / 2;
                
                if P(k)>(avg(k)+atr(k))
                    s(k) = 1;
                elseif P(k)<(avg(k)-atr(k));
                    s(k) = -1;
                end
                
            end
            
            % plot the supertrend signal
%             figure
%             sx(1) = subplot(2,1,1);
%             plot(P), grid on
%             hold on
%             plot(avg+atr)
%             plot(avg-atr)
%             sx(2) = subplot(2,1,2);
%             plot(s), grid on
%             linkaxes(sx,'x')

            i = 101;
            
            
            while i < sizeStorico
                
                % se il segnale è trending x due volte di seguito e poi smette di esserlo, 
                % compra sperando che il trend si inverta (-1 in long, 1 in short)
                if  ( abs( s(i-1) + s(i-2) ) == 2 ) && ( s(i) ~= s (i-1) )
                    
                    segnoOperazione = -s(i-1);
                    ntrades = ntrades + 1;
                    [obj, Pbuy, ~] = obj.apri(i, P, 0, ntrades, segnoOperazione, date);
                    
                    
                    
                    for j = (i+1):(sizeStorico-1)
                        
                        if s(j)==-segnoOperazione || ( segnoOperazione*(P(j) - Pbuy) < -50 )  % cioe' se il trend si inverte, chiudi
                            
                            obj.r(j) =  segnoOperazione*(P(j) - Pbuy) - cost;
                            obj.closingPrices(ntrades) = P(j);
                            obj.ClDates(ntrades) = date(j); %controlla
                            obj.minimumReturns(ntrades)=calculate_min_return(Pbuy, P(i:j), segnoOperazione);
                            i = j;
                            obj.chei(ntrades)=i;
                            obj.indexClose = obj.indexClose + 1;
                            obj.latency(ntrades)=j - obj.indexOpen;
                            %                                     display('operazione chiusa');
                            break
                            
                        end
                        
                        i = j;
                        obj.trades(i) = 1;
                        
                    end
                    
                    
                end
                
                i = i + 1;
                
            end
            

            
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
            obj.outputbkt(:,11) = obj.minimumReturns(1:obj.indexClose,1);      % minimum return touched during dingle operation
            
            obj.latency = obj.latency(1:obj.indexClose);
            obj.arrayAperture = obj.arrayAperture(1:obj.indexClose);
               
            
            
            % Plot a richiesta
            if plottami
                
                figure
                ax(1) = subplot(2,1,1);
                plot(P), grid on
                legend('Price')
                title('supertrend Results' )
                ax(2) = subplot(2,1,2);
                plot(cumsum(obj.outputbkt(:,4))), grid on
                legend('Cumulative Return')
                title('Cumulative Returns ')
                
            end %if
            
        end
        
        
        function [obj, Pbuy, devFluct2] = apri(obj, i, P, ~, ntrades, segnoOperazione, date)
            
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
        
        
    end
    
end


