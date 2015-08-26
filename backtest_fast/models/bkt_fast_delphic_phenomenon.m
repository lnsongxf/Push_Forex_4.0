classdef bkt_fast_delphic_phenomenon < handle
    
    
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
        
    end
    
    
    methods
        
        function obj = fast_delphic_phenomenon(obj, P, date, cost, M, N, plottami)
            
            % P=chiusure a timescale almeno alla mezz ora
            % date = date delle chiusure P
            % cost = spread per operazione (calcolato quando chiudi)
            % N = frequenza smooth alta (lead, in letteratura=18)
            % M = frequenza smooth bassa (lag, in letteratura=40)
            % plottami =1 se vuoi plot alla fine, se no =0
            
            
            %% utilizza indicatore "delphic_phenomenon" con due medie mobili e prezzo a mezz ore o più lungo
            % guarda qui: https://www.ig.com/it/il-delphic-phenomenon
            
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
            indexClose = 0;
            s = zeros(size(P));
            slead = zeros(size(P));
            slag = zeros(size(P));
            
            a = (1/N)*ones(1,N);
            lead = filter(a,1,P);
            
            b = (1/M)*ones(1,M);
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
                        if  ( slead==0 && slag )
                            condition1_long = 1;
                            % se invece lag>P>lead, potresti aprire in short...
                        elseif ( slag==0 && slead )
                            condition1_short = 1;
                        end
                        
                        % se poi P va sopra lead, apri long!
                        if ( condition1_long )
                            
                            if ( slead)
                                
                                % buy long
                                ntrades = ntrades + 1;
                                [obj, Pbuy, ~] = obj.apri(j, P, 0, ntrades, segnoOperazione, date);
                                
                                for k = j:length(P)
                                    
                                    i=k;
                                    obj.trades(i) = 1;
                                    if (slead==0)
                                        
                                        obj.r(i) = P(k) - Pbuy - cost;
                                        obj.closingPrices(ntrades) = P(k);
                                        obj.ClDates(ntrades) = date(k);
                                        indexClose = indexClose + 1;
                                        break
                                    
                                    end
                                    
                                end
                                break
                                
                            end
                            
                            % se poi P va sotto lead, apri short!
                        elseif (condition1_short)
                            
                            if ( slead==0)
                                
                                % sell short
                                ntrades = ntrades + 1;
                                [obj, Pbuy, ~] = obj.apri(j, P, 0, ntrades, segnoOperazione, date);
                                
                                for k = j:length(P)
                                    
                                    i=k;
                                    obj.trades(i) = 1;
                                    if (slead)
                                        
                                        obj.r(i) = - ( P(k) - Pbuy ) - cost;
                                        obj.closingPrices(ntrades) = P(k);
                                        obj.ClDates(ntrades) = date(k);
                                        indexClose = indexClose + 1;
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
                ax(1)=subplot(2,1,1);
                plot(P,'black', 'LineWidth',1.5)
                hold on
                plot(leadP,'red', 'LineWidth',1.5)
                plot(lagP,'blue', 'LineWidth',1.5)
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
            obj.chei(ntrades)=i;
            obj.openingPrices(ntrades) = Pbuy;
            obj.OpDates(ntrades) = date(i);
            
        end
        
        
    end
    
end


