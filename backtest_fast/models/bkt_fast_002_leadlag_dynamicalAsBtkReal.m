classdef bkt_fast_002_leadlag_dynamicalAsBtkReal < handle
    
    
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
        obj.indexClose;
        
    end
    
    
    methods
        
        function obj = spin(obj, Pminute, matrixNewHisData, ~, newTimeScale, N, M, cost, ~, ~, wTP, wSL, plottami)
            
            
            %% simula leadlag con TP e SL a seconda della volatilità
            
            P = matrixNewHisData(:,4);
            date = matrixNewHisData(:,6);
            
            pandl = zeros(size(P));
            obj.trades = zeros(size(P));
            obj.chei=zeros(size(P));
            obj.openingPrices=zeros(size(P));
            obj.closingPrices=zeros(size(P));
            obj.direction=zeros(size(P));
            obj.OpDates=zeros(size(P));
            obj.ClDates=zeros(size(P));
            obj.r =zeros(size(P));
            
            ntrades = 0;
            obj.indexClose = 0;
            s = zeros(size(P));
            
            
            
            a = (1/N)*ones(1,N);
            lead = filter(a,1,P);
            
            b = (1/M)*ones(1,M);
            lag = filter(b,1,P);
            fluctuationslag=abs(P-lag);
            
            % signals
            s(lead>lag) = 1;
            s(lag>lead) = -1;
            
            
            
            i = 101;
            
            
            while i <= length(P)
                
                % se il trend breve va sotto quello lungo compra long
                % se il trend breve va sopra quello lungo compra short
                if ( abs( s(i) - s(i-1) ) == 2 )
                    
                    segnoOperazione = - sign(s(i) - s(i-1));
                    ntrades = ntrades + 1;
                    [obj, Pbuy, devFluct2] = obj.apri(i, P, fluctuationslag, M, ntrades, segnoOperazione, date);
                    
                    TakeP = wTP*devFluct2;
                    StopL = wSL*devFluct2;
                    TakeProfitPrice = Pbuy + segnoOperazione * TakeP;
                    StopLossPrice =  Pbuy - segnoOperazione * StopL;
                    
                    for j = newTimeScale*(i):length(Pminute)
                        
                        indice_I = floor(j/newTimeScale);
                        
                        %%%%%%%%%%% dynamicalTPandSLManager
                        
                        if abs( (Pminute(j) - StopLossPrice) ) > abs(StopL)*1.2
                            
                            distance = floor(abs(Pminute(j) - StopLossPrice)/2);
                            
                            newStopL =  - segnoOperazione * ( (Pminute(j) - Pbuy) - segnoOperazione * distance );
                            
                            %display(strcat('dynamical SL, the new SL is',' ',num2str(newStopL)));
                            
                            StopLossPrice    = Pbuy - segnoOperazione * newStopL;
                            
                            StopL = newStopL;
                            
                        end
                        
                        % If the current price is above half TakeP, re-set the StopL and TakeP
                        if ( (Pminute(j) - TakeProfitPrice) * segnoOperazione ) >= 0
                            
                            newTakeP = TakeP + 4 + abs(Pminute(j) - TakeProfitPrice);
                            
                            TakeProfitPrice = Pbuy + segnoOperazione * newTakeP;
                            
                            newStopL = - TakeP + 2;
                            %display(strcat('dynamical TP = ',num2str(newTakeP),'/','dynamical SL = ',num2str(newStopL)));
                            
                            StopLossPrice    = Pbuy - segnoOperazione * newStopL;
                            
                            TakeP = newTakeP;
                            StopL = newStopL;
                            
                        end
                        
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


