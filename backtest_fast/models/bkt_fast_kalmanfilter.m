classdef bkt_fast_kalmanfilter < handle
    
    
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
        
        function obj = fast_kalmanfilter(obj, P1,P2,date,cost,wApri,wChiudi,plottami)
            
            % P1 = chiusure del primo asset
            % P2 = chiusure del secondo asset
            % date = array delle date
            % cost = spread per operazione (calcolato quando chiudi)
            % WApri = peso per ottimizzare il segnale di apertura
            % wChiudi = peso per ottimizzare il segnale di chiusura
            
            %% utilizza segnale del kalman filter 
                        
%             
%              pandl = zeros(size(P));
%             obj.trades = zeros(size(P));
%             obj.chei=zeros(size(P));
%             obj.openingPrices=zeros(size(P));
%             obj.closingPrices=zeros(size(P));
%             obj.direction=zeros(size(P));
%             obj.OpDates=zeros(size(P));
%             obj.ClDates=zeros(size(P));
%             obj.r =zeros(size(P));
%             
%             ntrades = 0;
%             indexClose = 0;
%             s = zeros(size(P));
            
            x = P1; % variabile indipendente
            y = P2; % variabile dipendente
            
            x=[x ones(size(x))]; % giusto in caso che la regressione sfori
            
            %%%% Algo come implementato nel libro 2 di Chan %%%%%
            
            delta=0.0001; % delta=1 gives fastest change in beta, delta=0.000....1 allows no change (like traditional linear regression).
            
            yhat=NaN(size(y)); % measurement prediction
            e=NaN(size(y)); % measurement prediction error
            Q=NaN(size(y)); % measurement prediction error variance
            
            % For clarity, we denote R(t|t) by P(t).
            % initialize R, P and beta.
            R=zeros(2);
            P=zeros(2);
            beta=NaN(2, size(x, 1));
            Vw=delta/(1-delta)*eye(2);
            Ve=0.001;
            
            
            % Initialize beta(:, 1) to zero
            beta(:, 1)=0;
            
            % Given initial beta and R (and P)
            for t=1:length(y)

                if (t > 1)
                    beta(:, t)=beta(:, t-1); % state prediction. Equation 3.7
                    R=P+Vw; % state covariance prediction. Equation 3.8
                end
                
                yhat(t)=x(t, :)*beta(:, t); % measurement prediction. Equation 3.9
                
                Q(t)=x(t, :)*R*x(t, :)'+Ve; % measurement variance prediction. Equation 3.10
                
                
                % Observe y(t)
                e(t)=y(t)-yhat(t); % measurement prediction error
                
                K=R*x(t, :)'/Q(t); % Kalman gain
                
                beta(:, t)=beta(:, t)+K*e(t); % State update. Equation 3.11
                P=R-K*x(t, :)*R; % State covariance update. Euqation 3.12
                
            end
            
            y2=[x(:, 1) y];
            
            longsEntry=e < -wApri*sqrt(Q); % a long position means we should buy EWC
            longsExit=e > -wChiudi*sqrt(Q);
            
            shortsEntry=e > wApri*sqrt(Q);
            shortsExit=e < wChiudi*sqrt(Q);
            
            numUnitsLong=zeroes(length(y2), 1);
            numUnitsShort=zeroes(length(y2), 1);

            
            numUnitsLong(1)=0;
            numUnitsLong(longsEntry)=1;
            numUnitsLong(longsExit)=0;

            
            numUnitsShort(1)=0;
            numUnitsShort(shortsEntry)=-1;
            numUnitsShort(shortsExit)=0;
            
            numUnits=numUnitsLong+numUnitsShort;
            positions=repmat(numUnits, [1 size(y2, 2)]).*[-beta(1, :)' ones(size(beta(1, :)'))].*y2; % [hedgeRatio -ones(size(hedgeRatio))] is the shares allocation, [hedgeRatio -ones(size(hedgeRatio))].*y2 is the dollar capital allocation, while positions is the dollar capital in each ETF.
            pnl=sum(lag(positions, 1).*(y2-lag(y2, 1))./lag(y2, 1) - cost, 2); % daily P&L of the strategy
            ret=pnl./sum(abs(lag(positions, 1)), 2); % return is P&L divided by gross market value of portfolio
            ret(isnan(ret))=0;
            
            
            obj.outputbkt(:,1) = abs(numUnits);                    % index of stick
            obj.outputbkt(:,2) = positions(:,1);      % opening price E' SBAGLIATO!!
            obj.outputbkt(:,3) = positions(:,2);        % closing price E' SBAGLIATO!!
            obj.outputbkt(:,4) = pnl;   % returns
            obj.outputbkt(:,5) = numUnits;              % direction
            obj.outputbkt(:,6) = ones(indexClose,1);                    % real
%             obj.outputbkt(:,7) = obj.OpDates(1:indexClose);              % opening date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
%             obj.outputbkt(:,8) = obj.ClDates(1:indexClose);                % closing date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
%             obj.outputbkt(:,9) = ones(indexClose,1)*1;                 % lots setted for single operation
            
            
            
            % Plot a richiesta
            if plottami
                
                figure;
                title('Kalman filter Results' );
                plot(cumprod(1+ret)-cost); % Cumulative compounded return
                
            end %if
            
        end
        
 

    end
    
end


