classdef bkt_fast_006_RSI < handle
    
    
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
        indexClose;
        
    end
    
    
    methods
        
        function obj = spin(obj, Pminute, matrixNewHisData, ~, newTimeScale, N, M, cost, ~, ~, wTP, wSL, plottami)
            
            % Pminute = prezzo al minuto
            % P = prezzo alla new time scale
            % date = data alla new time scale
            % N = periodo(relativo all new time scale) su cui si basa l RSI
            % M = M-period moving average
            % cost = spread per operazione (calcolato quando chiudi)
            % wSL = peso per calcolare quando chiuder per SL
            % wTP = peso per calcolare quando chiuder per TP
            
            %% utilizza segnale del relative strength index
            
            P = matrixNewHisData(:,4);
            date = matrixNewHisData(:,6);
            
            thresh = [30 70]; % default threshold for the RSI
            
            
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
            
            if M == 0
                ma = zeros(size(P));
            else
                ma = movavg(P,M,M,'e');
            end
            ri = rsindex(P - ma, N);
            
            
            indx    = ri < thresh(1);
            indx    = [false; indx(1:end-1) & ~indx(2:end)];
            s(indx) = 1;
            % Crossing the upper threshold
            indx    = ri > thresh(2);
            indx    = [false; indx(1:end-1) & ~indx(2:end)];
            s(indx) = -1;

            i = 101;
            
            
            while i <= length(P)
                
                % se RSI da il segnale, compra (-1 in short, +1 in long)
                if  abs ( s(i) ) 
                    
                    segnoOperazione = s(i);
                    ntrades = ntrades + 1;
                    [obj, Pbuy, devFluct2] = obj.apri(i, P, 0, M, ntrades, segnoOperazione, date);
                    
                    for j = newTimeScale*(i):length(Pminute)
                        
                        indice_I = floor(j/newTimeScale);
                        
                        cond1 = abs (Pminute(j) - Pbuy) >= floor(wTP*devFluct2);
                        cond2 = sign (Pminute(j) - Pbuy) == segnoOperazione;
                        cond3 = abs (Pminute(j) - Pbuy) >= floor(wSL*devFluct2);
                        cond4 = sign (Pminute(j) - Pbuy) == segnoOperazione*-1;
                        
                        if cond1 && cond2
                            
                            obj.r(indice_I) = wTP*devFluct2 - cost;
                            obj.closingPrices(ntrades) = Pbuy + segnoOperazione*floor(wTP*devFluct2);
                            obj.ClDates(ntrades) = date(indice_I); %controlla
                            %obj = obj.chiudi_per_TP(Pbuy, indice_I, segnoOperazione, devFluct2, wTP, cost, ntrades, date);
                            i = indice_I;
                            obj.chei(ntrades)=i;
                            obj.indexClose = obj.indexClose + 1;
                            break
                            
                        elseif cond3 && cond4
                            
                            obj.r(indice_I) = - wSL*devFluct2 - cost;
                            obj.closingPrices(ntrades) = Pbuy - segnoOperazione*floor(wSL*devFluct2);
                            obj.ClDates(ntrades) = date(indice_I); %controlla
                            %obj = obj.chiudi_per_SL(Pbuy, indice_I, segnoOperazione, devFluct2, wSL, cost, ntrades, date);
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
                ax(1) = subplot(3,1,1);
                plot([P,ma]), grid on
                legend('Price',['Moving Average ',num2str(M)])
                title('RSI Results' )
                ax(2) = subplot(3,1,2);
                plot([ri,thresh(1)*ones(size(ri)),thresh(2)*ones(size(ri))])
                grid on
                legend(['RSI ',num2str(N)],'Lower Threshold','Upper Threshold')
                title('RSI')
                aaa(1) = subplot(3,1,3);
                plot(cumsum(obj.outputbkt(:,4))), grid on
                legend('Cumulative Return')
                title('Cumulative Returns ')
                linkaxes(ax,'x')
                
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


