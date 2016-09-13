classdef bkt_fast_016_2_double_repo_closingWinMorePips < handle
    
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
        
        function obj = spin(obj, Pminute, matrixNewHisData, ~, newTimeScale, N, shift, cost, ~, ~, ~, ~, plottami)
            
            % Pminute = prezzo al minuto
            % matrixNewHisData = matrice con prezzi e date alla new time scale
            % N = numero di periodi di smoothing per la media mobile
            % shift = numero di periodi di cui shiftare la media mobile
            % cost = spread per operazione (calcolato quando chiudi)
            % wSL = peso per calcolare quando chiuder per SL
            % wTP = peso per calcolare quando chiuder per TP
            
            %% utilizza segnale del double repenetration
            
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
            
            a = (1/N)*ones(1,N);
            lead = filter(a,1,P);
            
            shiftedlead = [ nan(shift,1); lead(1:end-shift) ];
            
            s(P>=shiftedlead)=1;
            s(P<shiftedlead)=-1;
            
            i = 101; % 200 %this can be smaller (it's used to align the results to the bktoffline)
            
            trendLenght = 0;
            trigger1 = 0; % first penetration
            trigger2 = 0; % exit penetration
            
            while i < sizeStorico
                
                if ( trigger1~=0 && (i-trigger1)>15 ) % if too long has passed after the first penetration, reset
                    trigger1 = 0;
                    trigger2 = 0;
                    trendLenght = 0;
                end
                
                if (trigger1 == 0)
                    
                    % check if a trend is present for at least 8 periods
                    if ( s(i) == s(i-1) )
                        
                        strend = s(i);
                        trendLenght = trendLenght + 1;
                        
                        if (trendLenght == 1) % record the price when the trend starts
                            starTrendPrice = P(i-1);
                        end
                        
                    else % if the trend is finished, check how long was it and how big (in pips)
                        
                        if (trendLenght >= 8 && abs(P(i-1)-starTrendPrice)> 50 )
                            
                            trigger1 = i; % first penetration present
                            
                        else % trend not long enough
                            
                            trendLenght = 0;
                            trigger1 = 0;
                            
                        end
                        
                    end
                    
                    
                else % if trigger1 is on
                    
                    if (s(i) == strend)
                        
                        trigger2 = 1; % exit penetration
                        i = i+1;
                        
                    end
                    
                    if trigger2
                        
                        if (s(i) == -strend) % second penetration!!
                            
                            if ( (P(i) - starTrendPrice)*strend < 10) % if the current price is too close to the price at the start of the trend, don't open
                                
                                trigger1 = 0;
                                trigger2 = 0;
                                trendLenght = 0;
                                
                            else % if the trend is consistent, open
                                
                                segnoOperazione = s(i);  % I open opposite to the starting trend
                                ntrades = ntrades + 1;
                                obj.arrayAperture(ntrades)=i;
                                [obj, Pbuy, ~] = obj.apri(i, P, 0, ntrades, segnoOperazione, date);
                                %                           display(['Pbuy =', num2str(Pbuy), ' segno =', num2str(segnoOperazione)]);
                                
                                if segnoOperazione == 1
                                    Volatility = Pbuy - min(low(trigger1:i)) ;
                                else
                                    Volatility = max(high(trigger1:i)) - Pbuy ;
                                end
                                
                                TakeP = max(min(Volatility,50),5);
                                StopL = max(min(Volatility,50),5);
                                TakeProfitPrice = Pbuy + segnoOperazione * TakeP;
                                StopLossPrice =  Pbuy - segnoOperazione * StopL;
                                
                                for j = newTimeScale*(i):length(Pminute)
                                    
                                    indice_I = floor(j/newTimeScale);
                                    %                               display(['Pminute =', num2str(Pminute(j))]);
                                    
                                    %%%%%%%%%%% dynamicalTPandSLManager
                                    %
                                    dynamicParameters {1} = 8;
                                    dynamicParameters {2} = 8;
                                    
                                    [TakeProfitPrice,StopLossPrice,TakeP,StopL,~] = closingWinMorePips(Pbuy,Pminute(j),segnoOperazione,TakeP,StopL, 0, dynamicParameters);
%                                     display(['TP =', num2str(TakeP),' SL =', num2str(StopL)]);
%                                     display(['StopLossPrice =', num2str(StopLossPrice)]);
                                    
                                    %%%%%%%%%%%%%%%%%%%%%%%%%%
                                    
                                    
                                    condTP = ( sign( Pminute(j) - TakeProfitPrice ) * segnoOperazione );
                                    condSL = ( sign( StopLossPrice - Pminute(j) ) ) * segnoOperazione;
                                    
                                    if ( condTP >=0 ) || ( condSL >= 0 )
                                        
                                        obj.r(indice_I) =  segnoOperazione*(Pminute(j) - Pbuy) - cost;
                                        obj.closingPrices(ntrades) = Pminute(j);
                                        obj.ClDates(ntrades) = date(indice_I); %controlla
                                        obj.minimumReturns(ntrades)=calculate_min_return(Pbuy, Pminute(newTimeScale*obj.indexOpen:j), segnoOperazione);
                                        %obj = obj.chiudi_per_TP(Pbuy, indice_I, segnoOperazione, devFluct2, wTP, cost, ntrades, date);
                                        i = indice_I;
                                        obj.chei(ntrades)=i;
                                        obj.indexClose = obj.indexClose + 1;
                                        obj.latency(ntrades)=j - newTimeScale*obj.indexOpen;
                                        %                                     display('operazione chiusa');
                                        trigger1 = 0;
                                        trigger2 = 0;
                                        trendLenght = 0;
                                        break
                                        
                                    end
                                    
                                end
                                
                                i = indice_I;
                                obj.trades(i) = 1;
                                
                            end
                            
                        end
                        
                    end
                    
                end
                
                i = i+1;
                
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
                ax(1) = subplot(3,1,1);
                plot(P), grid on
                legend('Price','Location','best')
                title('Results' )
                ax(2) = subplot(3,1,2);
                plot(stosc(:,1))
                hold on
                plot(xlim, [1 1]*20, '-r')
                plot(xlim, [1 1]*80, '-r')
                legend('signal','Location','best')
                ax(3) = subplot(3,1,3);
                plot(cumsum(obj.outputbkt(:,4))), grid on
                legend('Cumulative Return','Location','best')
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
        
        
    end
    
end


