classdef bkt_fast_002_1_leadlag_closingForApproaching_3D < handle
    
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
        
        function obj = spin(obj, Pminute, matrixNewHisData, ~, newTimeScale, N, M, cost, ~, ~, wTP, wSL, Z)
            
            
            %% simula leadlag con TP e SL a seconda della volatilit�
            
            P = matrixNewHisData(:,4);
            date = matrixNewHisData(:,6);
            
            plottami = 0;
            
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
            
            b = (1/M)*ones(1,M);
            lag = filter(b,1,P);
            fluctuationslag=abs(P-lag);
            
            % signals
            s(lead>lag) = 1;
            s(lag>lead) = -1;
            
            
            
            i = 101;
            
            
            while i <= sizeStorico
                
                % se il trend breve va sotto quello lungo compra long
                % se il trend breve va sopra quello lungo compra short
                if ( abs( s(i) - s(i-1) ) == 2 )
                    
                    % questo e' il controllo sul fluctuation limit
                    devFluct2 = std(fluctuationslag((i-(100-M)):i));
                    if (devFluct2 > 4) % <- cambia il valore x cambiare fluctLimit
                        
                        segnoOperazione = - sign(s(i) - s(i-1));
                        ntrades = ntrades + 1;
                        obj.arrayAperture(ntrades)=i;
                        [obj, Pbuy, devFluct2] = obj.apri(i, P, fluctuationslag, M, ntrades, segnoOperazione, date);
                        
                        volatility = min(floor(wTP*devFluct2),50);
                        TakeP = volatility;
                        StopL = volatility;
                        TakeProfitPrice = Pbuy + segnoOperazione * TakeP;
                        StopLossPrice =  Pbuy - segnoOperazione * StopL;
                        
                        for j = newTimeScale*(i):length(Pminute)
                            
                            indice_I = floor(j/newTimeScale);
                            %                               display(['Pminute =', num2str(Pminute(j))]);
                            
                            %%%%%%%%%%% dynamicalTPandSLManager
                            
                            dynamicParameters {1} = Z/10; %1.18;
                            %dynamicParameters {2} = 2;
                            [TakeProfitPrice,StopLossPrice,TakeP,StopL,~] = closingForApproaching(Pbuy,Pminute(j),segnoOperazione,TakeP,StopL, 0, dynamicParameters);
%                             display(['TP =', num2str(TakeP),' SL =', num2str(StopL)]);
%                             display(['StopLossPrice =', num2str(StopLossPrice)]);
                            
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
            if plottami
                
                figure
                ax(1) = subplot(2,1,1);
                plot([P(M:end),lead(M:end),lag(M:end)],'LineWidth',1); grid on
                legend('Close',['Lead ',num2str(N)],['Lag ',num2str(M)],'Location','Best')
                title(['Lead/Lag EMA Results, Final Return = ',num2str(sum(obj.outputbkt(:,4)))])
                ax(2) = subplot(2,1,2);
                plot(obj.outputbkt(:,1),cumsum(obj.outputbkt(:,4))), grid on
                legend('Cumulative Return')
                title('Cumulative Returns ')
                
                
            end %if
            
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


