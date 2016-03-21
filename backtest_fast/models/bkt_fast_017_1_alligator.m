classdef bkt_fast_017_1_alligator < handle
    
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
        
        function obj = spin(obj, Pminute, matrixNewHisData, ~, newTimeScale, N, M, cost, ~, ~, wTP, wSL, plottami)
            
            
            %% simula leadlag con TP e SL a seconda della volatilità
            
            aperture = matrixNewHisData(:,1);
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
            s_trend = zeros(sizeStorico,1);
            s_doji = zeros(sizeStorico,1);
            
            
            a = (1/N)*ones(1,N);
            lead1 = filter(a,1,P);
            diff_lead1 = [ 0 ; diff(lead1) ];
            
            b = (1/M)*ones(1,M);
            lead2 = filter(b,1,P);
            diff_lead2 = [ 0 ; diff(lead2) ];
            fluctuationslag=abs(P-lead2);
            
            c = (1/13)*ones(1,13);
            lead3 = filter(c,1,P);
            diff_lead3 = [ 0 ; diff(lead3) ];
            
            % signal of the trend
            s_trend( intersect(intersect(find(diff_lead1>0),find(diff_lead2>0)),find(diff_lead3>0)) ) = 1;
            s_trend( intersect(intersect(find(diff_lead1<0),find(diff_lead2<0)),find(diff_lead3<0)) ) = -1;
            
            %signal of doji and engulfing
            
            close_meno_open = P - aperture;
            candle_sign = zeros(sizeStorico,1);
            candle_inversion = zeros(sizeStorico,1);
            candle_sign( close_meno_open > 0 ) = 1; % se chiusure son sopra le aperture
            candle_sign( close_meno_open < 0 ) = -1;
            diff_close_meno_open = [ 0 ; diff(candle_sign) ];
            candle_inversion( diff_close_meno_open==2 ) = 1;   % passato da calante a crescente
            candle_inversion( diff_close_meno_open==-2 ) = -1; % passato da crescente a calante
            
            s_doji( close_meno_open==0 ) = 1;
            
            go = 0;
            
            i = 101;
            
            
            while i <= sizeStorico
                
                % se c'e' trend, controlla se vedi una doji o un engulfing
                if ( abs( s_trend(i) ) )
                    
                    if ( s_doji(i) )
                        
%                         go = 1;
%                         segnoOperazione = s_trend(i);
%                         i = i+1; % in questo caso apri alla chiusura sucessiva
                        
                    % possible engulfing
                    elseif ( s_trend(i) == candle_inversion(i) )
                        
                        % bullish engulfing: inversione da prezzo calante a crescente,
                        % aperture(i) sotto le chiusure della candela precedente 
                        % e chiusure(i) sopra le aperture della candela precendente
                        if ( candle_inversion(i) == 1 && ( P(i-1) - aperture(i) ) > 0 && ( P(i) - aperture(i-1) ) > 0 )
                            
                            go = 1;
                            segnoOperazione = candle_inversion(i);
                            
                        % bearish engulfing: inversione da prezzo da crescente a calante,
                        % aperture(i) sopra le chiusure della candela precedente 
                        % e chiusure(i) sotto le aperture della candela precendente
                        elseif ( candle_inversion(i) == -1 && ( P(i-1) - aperture(i) ) < 0 && ( P(i) - aperture(i-1) ) < 0 )
                            
                            go = 1;
                            segnoOperazione = candle_inversion(i);
                            
                        end
                        
                    end
                    
                    if ( go == 1 )
                        
                        ntrades = ntrades + 1;
                        obj.arrayAperture(ntrades)=i;
                        [obj, Pbuy, devFluct2] = obj.apri(i, P, fluctuationslag, M, ntrades, segnoOperazione, date);
                        
                        volatility = min(floor(wTP*devFluct2),50);
                        TakeP = 15;
                        StopL = 15;
                        TakeProfitPrice = Pbuy + segnoOperazione * TakeP;
                        StopLossPrice =  Pbuy - segnoOperazione * StopL;
                        
                        for j = newTimeScale*(i):length(Pminute)
                            
                            indice_I = floor(j/newTimeScale);
                            %                               display(['Pminute =', num2str(Pminute(j))]);
                            
                            %%%%%%%%%%% dynamicalTPandSLManager
                            %
                            %                               dynamicParameters {1} = 1;
                            %                               dynamicParameters {2} = 2;
                            %                               [TakeProfitPrice,StopLossPrice,TakeP,StopL,~] = closingAfterReachedTP(Pbuy,Pminute(j),segnoOperazione,TakeP,StopL, 0, dynamicParameters);
                            %                               display(['TP =', num2str(TakeP),' SL =', num2str(StopL)]);
                            %                               display(['StopLossPrice =', num2str(StopLossPrice)]);
                            
                            %%%%%%%%%%%%%%%%%%%%%%%%%%
                            
                            
                            condTP = ( sign( Pminute(j) - TakeProfitPrice ) * segnoOperazione );
                            condSL = ( sign( StopLossPrice - Pminute(j) ) ) * segnoOperazione;
                            
                            
                            if ( condTP >=0 ) || ( condSL >= 0 )
                                
                                obj.r(indice_I) = (Pminute(j)-Pbuy)*segnoOperazione - cost;
                                obj.closingPrices(ntrades) = Pminute(j);
                                obj.minimumReturns(ntrades)=calculate_min_return(Pbuy, Pminute(newTimeScale*i:j), segnoOperazione);
                                obj.ClDates(ntrades) = date(indice_I); %controlla
                                i = indice_I;
                                obj.chei(ntrades)=i;
                                obj.indexClose = obj.indexClose + 1;
                                obj.latency(ntrades)=j - newTimeScale*obj.indexOpen;
                                go = 0;
                                break
                                
                            end
                            
                            i = indice_I;
                            obj.trades(i) = 1;
                            
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
            
            obj.outputbkt(:,1) = obj.chei(1:obj.indexClose);                 % index of stick
            obj.outputbkt(:,2) = obj.openingPrices(1:obj.indexClose);        % opening price
            obj.outputbkt(:,3) = obj.closingPrices(1:obj.indexClose);        % closing price
            obj.outputbkt(:,4) = (obj.closingPrices(1:obj.indexClose) - ...
                obj.openingPrices(1:obj.indexClose)).*obj.direction(1:obj.indexClose);   % returns
            obj.outputbkt(:,5) = obj.direction(1:obj.indexClose);            % direction
            obj.outputbkt(:,6) = ones(obj.indexClose,1);                     % real
            obj.outputbkt(:,7) = obj.OpDates(1:obj.indexClose);              % opening date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
            obj.outputbkt(:,8) = obj.ClDates(1:obj.indexClose);              % closing date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
            obj.outputbkt(:,9) = ones(obj.indexClose,1)*1;                   % lots setted for single operation
            obj.outputbkt(:,10) = obj.latency(1:obj.indexClose);             % number of minutes the operation was open
            obj.outputbkt(:,11) = obj.minimumReturns(1:obj.indexClose,1);      % minimum return touched during dingle operation
            
            obj.latency = obj.latency(1:obj.indexClose);
            obj.arrayAperture = obj.arrayAperture(1:obj.indexClose);
            
            % Plot a richiesta
%             if plottami
%                 
%                 figure
%                 ax(1) = subplot(2,1,1);
%                 plot([P(M:end),lead(M:end),lag(M:end)],'LineWidth',1); grid on
%                 legend('Close',['Lead ',num2str(N)],['Lag ',num2str(M)],'Location','Best')
%                 title(['Lead/Lag EMA Results, Final Return = ',num2str(sum(obj.outputbkt(:,4)))])
%                 ax(2) = subplot(2,1,2);
%                 plot(obj.outputbkt(:,1),cumsum(obj.outputbkt(:,4))), grid on
%                 legend('Cumulative Return')
%                 title('Cumulative Returns ')
%                 
%                 
%             end %if
            
        end
        
        
        function [obj, Pbuy, devFluct2] = apri(obj, i, P, fluctuationslag, M, ntrades, segnoOperazione, date)
            
            obj.trades(i) = 1;
            Pbuy = P(i);
            devFluct2 = std(fluctuationslag((i-(100-M)):i));
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


