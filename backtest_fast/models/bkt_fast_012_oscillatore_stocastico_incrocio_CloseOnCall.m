classdef bkt_fast_011b_oscillatore_stocastico_CloseOnCall < handle
    
    
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
        signal;
        
    end
    
    
    methods
        
        function obj = fast_oscillatore_stocastico(obj, Pminute,matrixNewHisData, kperiods, dperiods ,newTimeScale,cost,wSL,wTP,plottami)
            
            % Pminute = prezzo al minuto
            % matrixNewHisData = matrice con prezzi e date alla new time scale
            % kperiods = numero di periodi %K (consigliato = 10)
            % dperiods = numero di periodi %D (consigliato = 3)
            % cost = spread per operazione (calcolato quando chiudi)
            % wSL = peso per calcolare quando chiuder per SL
            % wTP = peso per calcolare quando chiuder per TP
            % NOTE : it is implemented to close either for TP or SL, or ON CALL if the indicator reverts
            
            %% utilizza segnale dell'oscillatore stocastico
            % https://www.ig.com/it/oscillatore-stocastico-prima-parte
            
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
            obj.signal = zeros(sizeStorico,1);
            
            ntrades = 0;
            indexClose = 0;
            s = zeros(sizeStorico,1);
            incrocio = zeros(sizeStorico,1);
            
            stosc = stochosc(high, low, P, kperiods, dperiods);
            FpK = stosc(:,1);
            FpD = stosc(:,2);
            
            s(FpK<20) = 1;
            s(FpK>80) = -1;
            
            incrocio = sign(FpK-FpD);
            
            obj.signal = s;
            
            
            
            i = kperiods + 1;
            
            
            while i <= sizeStorico
                
                % se il segnale passa da ipercomprato/venduto a non, compra (1 in long, -1 in short)
                if  ( abs( s(i) ) && incrocio(i-1)~=incrocio(i) )
                    
                    segnoOperazione = s(i-1);
                    ntrades = ntrades + 1;
                    [obj, Pbuy, devFluct2] = obj.apri(i, P, 0, ntrades, segnoOperazione, date);
                    
                    TakeP = wTP*devFluct2;
                    StopL = wSL*devFluct2;
                    TakeProfitPrice = Pbuy + segnoOperazione * TakeP;
                    StopLossPrice =  Pbuy - segnoOperazione * StopL;
                    
                    for j = newTimeScale*(i):length(Pminute)
                        
                        indice_I = floor(j/newTimeScale);
                        
                        condTP = ( sign( Pminute(j) - TakeProfitPrice ) * segnoOperazione );
                        condSL = ( sign( StopLossPrice - Pminute(j) ) ) * segnoOperazione;
                        cond5 = abs( s(indice_I) - segnoOperazione ) >= 2;
                        
                       if ( condTP >=0 )
                            
                            slope=floor( segnoOperazione*mean( diff(Pminute( (j-5):j ) ) ) );
                            if slope > 5
                                %display(num2str(slope));
                                if (slope > 20)
                                    slope = 20;
                                end
                                TakeProfitPrice =  Pminute(j) +segnoOperazione*slope;
                                StopLossPrice =  Pminute(j) -segnoOperazione*slope;
                                
                            else
                                
                                obj.r(indice_I) = segnoOperazione*(Pminute(j) - Pbuy) - cost;
                                obj.closingPrices(ntrades) = Pminute(j);
                                obj.ClDates(ntrades) = date(indice_I); %controlla
                                %obj = obj.chiudi_per_TP(Pbuy, indice_I, segnoOperazione, devFluct2, wTP, cost, ntrades, date);
                                i = indice_I;
                                obj.chei(ntrades)=i;
                                indexClose = indexClose + 1;
                                break
                                
                            end
                            
                        elseif ( condSL >= 0 )
                            
                            obj.r(indice_I) = segnoOperazione*(Pminute(j) - Pbuy) - cost;
                            obj.closingPrices(ntrades) = Pminute(j);
                            obj.ClDates(ntrades) = date(indice_I); %controlla
                            %obj = obj.chiudi_per_SL(Pbuy, indice_I, segnoOperazione, devFluct2, wSL, cost, ntrades, date);
                            i = indice_I;
                            obj.chei(ntrades)=i;
                            indexClose = indexClose + 1;
                            break
                            
                        elseif cond5
                            
                            obj.r(indice_I) = segnoOperazione*(Pminute(j) - Pbuy) - cost;
                            obj.closingPrices(ntrades) = Pminute(j);
                            obj.ClDates(ntrades) = date(indice_I); %controlla
                            i = indice_I;
                            obj.chei(ntrades)=i;
                            indexClose = indexClose + 1;
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
            
            obj.outputbkt(:,1) = obj.chei(1:indexClose);                    % index of stick
            obj.outputbkt(:,2) = obj.openingPrices(1:indexClose);      % opening price
            obj.outputbkt(:,3) = obj.closingPrices(1:indexClose);        % closing price
            obj.outputbkt(:,4) = (obj.closingPrices(1:indexClose) - ...
                obj.openingPrices(1:indexClose)).*obj.direction(1:indexClose);   % returns
            obj.outputbkt(:,5) = obj.direction(1:indexClose);              % direction
            obj.outputbkt(:,6) = ones(indexClose,1);                    % real
            obj.outputbkt(:,7) = obj.OpDates(1:indexClose);              % opening date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
            obj.outputbkt(:,8) = obj.ClDates(1:indexClose);                % closing date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
            obj.outputbkt(:,9) = ones(indexClose,1)*1;                 % lots setted for single operation
            
            
            
            % Plot a richiesta
            if plottami
                
                figure
                ax(1) = subplot(3,1,1);
                plot(P), grid on
                legend('Price','Location','best')
                title('stochastic oscill. Results' )
                ax(2) = subplot(3,1,2);
                plot(stosc)
                hold on
                plot(xlim, [1 1]*20, '-r')
                plot(xlim, [1 1]*80, '-r')
                legend('Stochastic oscill signal','Location','best')
                linkaxes(ax,'x')
                bx = subplot(3,1,3);
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


