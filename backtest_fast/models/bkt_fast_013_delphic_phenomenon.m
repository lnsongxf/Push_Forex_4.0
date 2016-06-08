classdef bkt_fast_013_delphic_phenomenon < handle
    
    
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
        
        function obj = spin(obj, ~, matrixNewHisData, ~, ~, N, M, cost, ~, ~, ~, ~, plottami)
            
            % P=chiusure a timescale almeno alla mezz ora
            % date = date delle chiusure P
            % cost = spread per operazione (calcolato quando chiudi)
            % N = frequenza smooth alta (lag, in letteratura=40)
            % M = frequenza smooth bassa (lead, in letteratura=18)
            % plottami =1 se vuoi plot alla fine, se no =0
            
            
            %% utilizza indicatore "delphic_phenomenon" con due medie mobili e prezzo a mezz ore o più lungo
            % guarda qui: https://www.ig.com/it/il-delphic-phenomenon
            
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
            slead = zeros(size(P));
            slag = zeros(size(P));
            
            a = (1/M)*ones(1,M);
            lead = filter(a,1,P);
            
            b = (1/N)*ones(1,N);
            lag = filter(b,1,P);
            
            s(lead>lag)=1;
            s(lead<lag)=-1;
            
            % slead dice se P è maggiore di lead
            slead(P>lead)=1;
            
            % slag dice se P è maggiore di lag
            slag(P>lag)=1;
            
            condition1_long = 0;
            condition1_short= 0;
            
            i = 101;
            
            
            while i <= length(P)
                
                % se lead e lag si incrociano, stai attento a che succede...
                if  ( abs( s(i) - s(i-1) ) == 2  || s(i-1) == 0 )
                    
                    segnoOperazione = s(i);
                    
                    for j = (i+1):length(P)
                        
                        i=j;
                        % se lead e lag si reincrociano, lascia perdere
                        if segnoOperazione ~= s(j)
                            break
                        end
                        
                        % se lead>P>lag, potresti aprire in long...
                        if  ( slead(j)==0 && slag(j) )
                            condition1_long = 1;
                            % se invece lag>P>lead, potresti aprire in short...
                        elseif ( slag(j)==0 && slead(j) )
                            condition1_short = 1;
                        end
                        
                        % se poi P va sopra lead, apri long!
                        if ( condition1_long )
                            
                            if ( slead(j) )
                                
                                % buy long
                                ntrades = ntrades + 1;
                                [obj, Pbuy, ~] = obj.apri(j, P, 0, ntrades, segnoOperazione, date);
                                
                                for k = j:length(P)
                                    
                                    i=k;
                                    obj.trades(i) = 1;
                                    if (slead(k)==0)
                                        
                                        obj.r(i) = P(k) - Pbuy - cost;
                                        obj.closingPrices(ntrades) = P(k);
                                        obj.ClDates(ntrades) = date(k);
                                        obj.chei(ntrades)=i;
                                        obj.indexClose = obj.indexClose + 1;
                                        break
                                        
                                    end
                                    
                                end
                                break
                                
                            end
                            
                            % se poi P va sotto lead, apri short!
                        elseif (condition1_short)
                            
                            if ( slead(j)==0)
                                
                                % sell short
                                ntrades = ntrades + 1;
                                [obj, Pbuy, ~] = obj.apri(j, P, 0, ntrades, segnoOperazione, date);
                                
                                for k = j:length(P)
                                    
                                    i=k;
                                    obj.trades(i) = 1;
                                    if (slead(k))
                                        
                                        obj.r(i) = - ( P(k) - Pbuy ) - cost;
                                        obj.closingPrices(ntrades) = P(k);
                                        obj.ClDates(ntrades) = date(k);
                                        obj.chei(ntrades)=i;
                                        obj.indexClose = obj.indexClose + 1;
                                        break
                                        
                                    end
                                    
                                end
                                break
                                
                            end
                            
                            
                            
                        end
                        
                        
                        
                    end
                    
                    
                    
                    
                end
                
                i = i + 1;
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
            
            
            
            % Plot a richiesta
            if plottami
                
                figure
                ax(1)=subplot(2,1,1);
                plot(P,'black', 'LineWidth',1.5)
                hold on
                plot(lead,'red', 'LineWidth',1.5)
                plot(lag,'blue', 'LineWidth',1.5)
                grid(ax(1),'on');
                
                legend('Price','lead','lag')
                ax(2) = subplot(2,1,2);
                plot(cumsum(obj.outputbkt(:,4))), grid on
                legend('Cumulative Return')
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
        
        
    end
    
end


