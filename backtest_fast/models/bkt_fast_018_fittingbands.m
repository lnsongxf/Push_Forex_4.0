classdef bkt_fast_018_fittingbands < handle
    
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
        
        function obj = spin(obj, Pminute, matrixNewHisData, ~, newTimeScale, npunti, ~, cost, ~, ~, ~, ~, plottami)
            
            % Pminute = prezzo al minuto
            % P = prezzo alla new time scale
            % date = data alla new time scale
            % cost = spread per operazione (calcolato quando chiudi)
            % npunti = lookback period per calcolare il fit
            
            
            %% simula delle bande sulla derivata di un fit lineare e apre considerando una mean reversion
            
            %             hi = matrixNewHisData(:,2);
            %             lo = matrixNewHisData(:,3);
            P = matrixNewHisData(:,4);
            date = matrixNewHisData(:,6);
            
            sizeStorico = size(matrixNewHisData,1);
            
%             pandl = zeros(sizeStorico,1);
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
            
            movingLead = zeros(sizeStorico,1);
            
            mu = mean(P);
            standev = std(P);
            Pscal = (P - mu) / standev; %% scalato per velocizzare il fit
            
            
            for k=npunti:sizeStorico
                
                b(:,1) = k-(npunti-1):k;
                myfitLead = fit( b, Pscal(b), 'poly1' );
                movingLead(k) = myfitLead.p1*k + myfitLead.p2;
                
            end
            
            %riscala ai valori corretti del cross
            movingLead = movingLead * standev + mu;
            
            derivLead = [0 ; diff(movingLead)];
            
            % calcolo le statistiche usando una finestra 2x quella del fit
            meanLead = movingAvg(derivLead, 2*npunti);
            sigmaLead = movingStd(derivLead, 2*npunti);
            
            s( derivLead > (meanLead+sigmaLead) ) = 1;
            s( derivLead < (meanLead-sigmaLead) ) = -1;
            
            i = 101;
            
            trigger1 = 0;
            
            while i < sizeStorico
                
                % se la derivata torna all'interno delle bande, aspetta che
                % vada a 0 poi fai partire l'operazione in senso opposto
                if   ( abs(s(i-1)) && abs( s(i) - s(i-1) ) == 1 )
                    
                    segnoOperazione = -s(i-1); %per sicurezza metto i-1 csi sn sicuro nn ha cambiato gia' segno
                    trigger1 = 1;
                    Ptrigger = P(i-1); % provo a prender il prezzo a i-1 come aiuto x determinare il TP e SL
                    
                end
                
                if ( (trigger1) && (sign(derivLead(i)) ~= sign(derivLead(i-1)) ) )
                    
                    ntrades = ntrades + 1;
                    obj.arrayAperture(ntrades)=i;
                    [obj, Pbuy, ~] = obj.apri(i, P, 0, 0, ntrades, segnoOperazione, date);
                    
                    TakeP = max(abs(Ptrigger - Pbuy),10); % BAH, CAMBIA MAGARI!
                    StopL = max(abs(Ptrigger - Pbuy),10);
                    TakeProfitPrice = Pbuy + segnoOperazione * TakeP;
                    StopLossPrice =  Pbuy - segnoOperazione * StopL;
                    %
                    %                     display(['Pbuy =' num2str(Pbuy)]);
                    %                     display(['segnoOperazione =' num2str(segnoOperazione)]);
                    %                     display(['TakeProfitPrice =' num2str(TakeProfitPrice)]);
                    %                     display(['StopLossPrice =' num2str(StopLossPrice)]);
                    %
                    for j = newTimeScale*(i):length(Pminute)
                        
                        indice_I = floor(j/newTimeScale);
                        
                        %%%%%%%%%%% dynamicalTPandSL
                        
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
                            trigger1 = 0;
                            %                             display( '---------------------' );
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
            
            
        end
        
    end
    
    
