classdef bkt_fast_016_oscillatore_stocastico_dontloose_semigood < handle
    
    
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
        
        function obj = spin(obj, Pminute, matrixNewHisData, ~, newTimeScale, kperiods, lateSL, cost, ~, ~, wTP, wSL, plottami)
            
            % Pminute = prezzo al minuto
            % matrixNewHisData = matrice con prezzi e date alla new time scale
            % kperiods = numero di periodi %K (consigliato = 10)
            % lateSL = a quanto risettare lo SL dopo che dontloose ha sbagliato a calcolarlo
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
            
            ntrades = 0;
            obj.indexClose = 0;
            s = zeros(sizeStorico,1);
            
            stosc = stochosc(high, low, P, kperiods, 1);
            FpK = stosc(:,1);
            %FpD = stosc(:,2);
            
            % I use a single oscillator as signal generator
            s(FpK<20) = 1;
            s(FpK>80) = -1;
            
            i = 101; %this can be as small as kperiods+1 (it's used to align the results to the bktoffline)
            
            
            while i <= sizeStorico
                
                % se il segnale passa da ipercomprato/venduto a non, compra (1 in long, -1 in short)
                if  ( abs( s(i-1) ) && s(i)==0 )
                    
                    segnoOperazione = s(i-1);
                    ntrades = ntrades + 1;
                    [obj, Pbuy, devFluct2] = obj.apri(i, P, 0, ntrades, segnoOperazione, date);
%                     display(['Pbuy =', num2str(Pbuy), ' segno =', num2str(segnoOperazione)]);
                    TakeP = min(floor(wTP*devFluct2),100);
                    StopL = min(floor(wSL*devFluct2),100);
                    TakeProfitPrice = Pbuy + segnoOperazione * TakeP;
                    StopLossPrice =  Pbuy - segnoOperazione * StopL;
                    
                    for j = newTimeScale*(i):length(Pminute)
                        
                        indice_I = floor(j/newTimeScale);
%                         display(['Pminute =', num2str(Pminute(j))]);
                        %%%%%%%%%%% dynamicalTPandSLManager
                        
                        dynamicParameters {1} = 0;
                        dynamicParameters {2} = 1;
                        dynamicParameters {3} = lateSL;
                        [TakeProfitPrice,StopLossPrice,TakeP,StopL,~] = closingDontloose(Pbuy,Pminute(j),segnoOperazione,TakeP,StopL, 0, dynamicParameters);
%                         display(['TP =', num2str(TakeP),' SL =', num2str(StopL)]);
%                         display(['StopLossPrice =', num2str(StopLossPrice)]);
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        condTP = ( sign( Pminute(j) - TakeProfitPrice ) * segnoOperazione );
                        condSL = ( sign( StopLossPrice - Pminute(j) ) ) * segnoOperazione;
                        
                        if ( condTP >=0 ) || ( condSL >= 0 )
                            
                            obj.r(indice_I) =  segnoOperazione*(Pminute(j) - Pbuy) - cost;
                            obj.closingPrices(ntrades) = Pminute(j);
                            obj.ClDates(ntrades) = date(indice_I); %controlla
                            %obj = obj.chiudi_per_TP(Pbuy, indice_I, segnoOperazione, devFluct2, wTP, cost, ntrades, date);
                            i = indice_I;
                            obj.chei(ntrades)=i;
                            obj.indexClose = obj.indexClose + 1;
                            obj.latency(ntrades)=j - newTimeScale*obj.indexOpen;
%                             display('operazione chiusa');
                            break
                            
                        end
                        
                    end
                    
                    i = indice_I;
                    obj.trades(i) = 1;
                    
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
                ax(1) = subplot(3,1,1);
                plot(P), grid on
                legend('Price','Location','best')
                title('stochastic oscill. Results' )
                ax(2) = subplot(3,1,2);
                plot(stosc(:,1))
                hold on
                plot(xlim, [1 1]*20, '-r')
                plot(xlim, [1 1]*80, '-r')
                legend('Stochastic oscill signal','Location','best')
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


