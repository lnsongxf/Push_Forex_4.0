classdef bkt_fast_005b_inverted_macd_dynamicalTPandSL < handle
    
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
        
        function obj = spin(obj, Pminute, matrixNewHisData, ~, newTimeScale, N, ~, cost, ~, ~, wTP, wSL, plottami)
            
            % Pminute = prezzo al minuto
            % P = prezzo alla new time scale
            % date = data alla new time scale
            % cost = spread per operazione (calcolato quando chiudi)
            % wSL = peso per calcolare quando chiuder per SL
            % wTP = peso per calcolare quando chiuder per TP
            
            %% utilizza segnale del moving average convergence divergence xo opera in senso opposto, come mean reverting invece che trending
            
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
            
            [macdvec, nineperma] = macd(P); % macdvec e' il segnale del macd mentre nineperma e' la 0 line
            s=macdvec-nineperma; % in teoria quando si incrociano dovrebbe partire il trend (segnale del macdvec)
            s(s>0)=1;
            s(s<0)=-1;
            
            b = (1/N)*ones(1,N);
            lag = filter(b,1,P);
            fluctuationslag=abs(P-lag);
            
            i = 101;
            
            
            while i < sizeStorico
                
                % se il segnale si inverte, compra (-1->+1 in long, se no in short)
                if  ( abs( s(i) - s(i-1) ) == 2 )
                    
                    segnoOperazione = -s(i); %%% HO INVERTITO IL SEGNO!! FUUNZIONA COME MEAN REVERTING!!
                    ntrades = ntrades + 1;
                    obj.arrayAperture(ntrades)=i;
                    [obj, Pbuy, devFluct2] = obj.apri(i, P, fluctuationslag, N, ntrades, segnoOperazione, date);
                    
                    TakeP = min(max(floor(wTP*devFluct2),50),200);
                    StopL = min(max(floor(wSL*devFluct2),50),200);
                    
                    TakeProfitPrice = Pbuy + segnoOperazione * TakeP;
                    StopLossPrice =  Pbuy - segnoOperazione * StopL;
                    
                    for j = newTimeScale*(i):length(Pminute)
                        
                        indice_I = floor(j/newTimeScale);
                        %                               display(['Pminute =', num2str(Pminute(j))]);
                        
                        %%%%%%%%%%% dynamicalTPandSLManager
                        %
                        %                                     dynamicParameters {1} = 1;
                        %                                     dynamicParameters {2} = 1;
                        %
                        %                                     [TakeProfitPrice,StopLossPrice,TakeP,StopL,~] = closingAfterReachedTP(Pbuy,Pminute(j),segnoOperazione,TakeP,StopL, 0, dynamicParameters);
                        %                               display(['TP =', num2str(TakeP),' SL =', num2str(StopL)]);
                        %                               display(['StopLossPrice =', num2str(StopLossPrice)]);
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        
                        condTP = ( sign( Pminute(j) - TakeProfitPrice ) * segnoOperazione );
                        condSL = ( sign( StopLossPrice - Pminute(j) ) ) * segnoOperazione;
                        
                        if ( condTP >=0 ) || ( condSL >= 0 )
                            
                            obj.r(indice_I) =  segnoOperazione*(Pminute(j) - Pbuy) - cost;
                            obj.closingPrices(ntrades) = Pminute(j);
                            obj.ClDates(ntrades) = date(indice_I); %controlla
                            obj.minimumReturns(ntrades)=calculate_min_return(Pbuy, Pminute(newTimeScale*i:j), segnoOperazione);
                            %obj = obj.chiudi_per_TP(Pbuy, indice_I, segnoOperazione, devFluct2, wTP, cost, ntrades, date);
                            i = indice_I;
                            obj.chei(ntrades)=i;
                            obj.indexClose = obj.indexClose + 1;
                            obj.latency(ntrades)=j - newTimeScale*obj.indexOpen;
                            %                                     display('operazione chiusa');
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
                legend('Price')
                title('macd Results' )
                ax(2) = subplot(2,1,2);
                plot(cumsum(obj.outputbkt(:,4))), grid on
                legend('Cumulative Return')
                title('Cumulative Returns ')
                
            end %if
            
        end
        
        
        function [obj, Pbuy, devFluct2] = apri(obj, i, P,fluctuationslag, N, ntrades, segnoOperazione, date)
            
            obj.trades(i) = 1;
            Pbuy = P(i);
            devFluct2 = std(fluctuationslag((i-(100-N)):i));
            obj.direction(ntrades)= segnoOperazione;
            obj.openingPrices(ntrades) = Pbuy;
            obj.OpDates(ntrades) = date(i);
            obj.indexOpen = i;
            
        end
        
        % Faster implementation of rsindex found in Financial Toolbox
        function r=rsindex(x,N)
            %L = length(x);
            dx = diff([0;x]);
            up=dx;
            down=abs(dx);
            % up and down moves
            I=dx<=0;
            up(I) = 0;
            down(~I)=0;
            % calculate exponential moving averages
            m1 = movavg(up,N,N,'e'); m2 = movavg(down,N,N,'e');
            warning off
            r = 100*m1./(m1+m2);
            %r(isnan(r))=50;
            I2=~((up+down)>0);
            r(I2)=50;
            
            warning on
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


