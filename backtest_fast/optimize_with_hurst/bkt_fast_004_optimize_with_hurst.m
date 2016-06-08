classdef bkt_fast_004_optimize_with_hurst < handle
    
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
        
        function obj = spin(obj, Pminute, matrixNewHisData, ~, newTimeScale, N, M, cost, ShrinkTP, ShrinkSL, wTP, wSL, plottami, smoothHurstDiff)
            
            
            %% simula leadlag con TP e SL a seconda della volatilità
            
            P = matrixNewHisData(:,4);
            date = matrixNewHisData(:,6);
            
            sizeStorico = size(matrixNewHisData,1);
            
            
            %pandl = zeros(size(P));
            obj.trades = zeros(size(P));
            obj.chei=zeros(size(P));
            obj.openingPrices=zeros(size(P));
            obj.closingPrices=zeros(size(P));
            obj.direction=zeros(size(P));
            obj.OpDates=zeros(size(P));
            obj.ClDates=zeros(size(P));
            obj.r =zeros(size(P));
            obj.latency= zeros(sizeStorico,1);
            obj.arrayAperture= zeros(sizeStorico,1);
            obj.minimumReturns = zeros(sizeStorico,1);
            
            ntrades = 0;
            obj.indexClose = 0;
            s = zeros(size(P));
            
            a = (1/M)*ones(1,M);
            lead = filter(a,1,P);
            
            b = (1/N)*ones(1,N);
            lag = filter(b,1,P);
            fluctuationslag=abs(P-lag);
            
            gradient1 = sign( diff(lead) );
            gradient2 = sign( diff(lag) );
            s_gradient = (gradient1 .* gradient2);
            
            % signals
            s(lead>lag) = 1;
            s(lag>lead) = -1;
            
            i = 100;
            
            
            while i < sizeStorico
                
                % se lead e lag si incrociano, parte un segnale...
                %if ( s(i)*s(i-1) < 0  ) && ( s_gradient(i-1) + s_gradient(i-2) == 2 )
                
                if ( s(i)*s(i-1) < 0  ) && ( smoothHurstDiff(i) > 0 )
                
                    segnoOperazione = gradient2(i-1) ;
                    ntrades = ntrades + 1;
                    obj.arrayAperture(ntrades)=i;
                    [obj, Pbuy, devFluct2] = obj.apri(i, P, fluctuationslag, N, ntrades, segnoOperazione, date);
                    
                    TakeP = min(floor(wTP*devFluct2),100);
                    StopL = min(floor(wSL*devFluct2),100);
                    TakeProfitPrice = Pbuy + segnoOperazione * TakeP;
                    StopLossPrice =  Pbuy - segnoOperazione * StopL;
                    
                    for j = newTimeScale*(i):length(Pminute)
                        
                        indice_I = floor(j/newTimeScale);
                        
                        %%%%%%%%%%% dynamicalTPandSLManager
                        
                        dynamicParameters {1} = ShrinkTP;
                        dynamicParameters {2} = ShrinkSL;
                        [TakeProfitPrice,StopLossPrice,TakeP,StopL,~] = closingShrinkingBands(Pbuy,Pminute(j),segnoOperazione,TakeP,StopL, 0, dynamicParameters);
                        
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
            obj.outputbkt(:,10) = obj.latency(1:obj.indexClose);        % number of minutes the operation was open
            obj.outputbkt(:,11) = obj.minimumReturns(1:obj.indexClose,1);      % minimum return touched during dingle operation
            
            obj.latency = obj.latency(1:obj.indexClose);
            obj.arrayAperture = obj.arrayAperture(1:obj.indexClose);
            
            
            % Plot a richiesta
            if plottami
                
                figure
                ax(1) = subplot(2,1,1);
                plot([P(N:end),lead(N:end),lag(N:end)],'LineWidth',1); grid on
                legend('Close',['Lead ',num2str(M)],['Lag ',num2str(N)],'Location','Best')
                title(['Lead/Lag EMA Results, Final Return = ',num2str(sum(obj.outputbkt(:,4)))])
                ax(2) = subplot(2,1,2);
                plot(obj.outputbkt(:,1),cumsum(obj.outputbkt(:,4))), grid on
                legend('Cumulative Return')
                title('Cumulative Returns ')
                
                
            end %if
            
        end
        
        
        function [obj, Pbuy, devFluct2] = apri(obj, i, P, fluctuationslag, N, ntrades, segnoOperazione, date)
            
            obj.trades(i) = 1;
            Pbuy = P(i);
            devFluct2 = mean(fluctuationslag((i-(100-N)):i));  %% used in algo004starttrend
            %devFluct2 = std(fluctuationslag((i-(100-N)):i));  %% used in algo002leadlag
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


