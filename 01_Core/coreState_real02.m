classdef coreState_real02 < handle
    
    properties
        state
        suggestedDirection
        suggestedTP
        suggestedSL
        P
        dev
        med
    end
    
    
    methods
        
        %% filtro Anderson-Darling
        
        % valuta la probabilità che n dati presi in input siano
        % distribuiti in maniera Gausssiana
        
        function obj = anderson(obj,data,Pa1,Pa2)
            
            %tic
            maxValues=data(:,2);
            minValues=data(:,3);
            
            fluct=maxValues-minValues;
            n=length(fluct);
            
            fluctMean=mean(fluct);
            fluctStd=std(fluct);
            
            fluctSort=sort(fluct);
            
            % standardizzazione
            fluctS=(fluctSort-fluctMean)/fluctStd;
            
            %calcolo Asquare (As)
            Pmean=mean(fluctS);
            Pstd=std(fluctS);
            CDF = normcdf(fluctS,Pmean,Pstd);
            m=0;
            
            for i=1:n
                a=(2*i)-1;
                b=log(CDF(i));
                c=log(1-CDF(n+1-i));
                m=m+(a*(b+c));
            end
            
            mM=m/n;
            As=-n-mM;
            Ass=As*((1+4/n)-(25/(n^2)));
            
            obj.P = 0;
            if (Ass >= 0.00 && Ass < 0.200);
                obj.P = 1 - exp(-13.436 + 101.14*Ass - 223.73*Ass^2);
            elseif (Ass >= 0.200 && Ass < 0.340);
                obj.P = 1 - exp(-8.318 + 42.796*Ass - 59.938*Ass^2);
            elseif (Ass >= 0.340 && Ass < 0.600);
                obj.P = exp(0.9177 - 4.279*Ass - 1.38*Ass^2);
            elseif (Ass >= 0.600 && Ass <= 13);
                obj.P = exp(1.2937 - 5.709*Ass + 0.0186*Ass^2);
            end
            
            if obj.P > Pa1 && obj.P < Pa2
                obj.state=1;
            else
                obj.state=0;
            end
            
            %display(Ass);
            %toc
        end
        
        
        
        
        
        %% filtro a priori sul "dev"
        
        % calcola il "dev" usando la funzione simul e poi filtra "state" sui
        % valori di "dev"
        
        function obj = simulCore(obj,closurePrices,devMin,devMax)
            %function [ w, l, dev,med ] = simulCore( data, stopLoss, takeProfit )
            
            % calcola le ampiezze tra chiusure
            data=closurePrices;
            amp = getSimpleAmplitude(data);
            pd  = fitdist(amp','normal');
            
            obj.dev = pd.std;
            obj.med = pd.mean;
            
            if obj.dev > devMin && obj.dev < devMax
                obj.state=1;
            else
                obj.state=0;
            end
            
            
        end
        
        
        
        
        function obj= simulCore2(obj,massimiPrices,minimiPrices,devMin,devMax)
            
            %calcola le ampiezze delle fluttuazioni
            maxP=massimiPrices;
            minP=minimiPrices;
            a=maxP-minP;
            pd  = fitdist(a,'normal');
            
            obj.dev = pd.std;
            obj.med = pd.mean;
            
            if obj.dev > devMin && obj.dev < devMax
                obj.state=1;
            else
                obj.state=0;
            end
            
            
        end
        
        
        %% decision REAL 3 a priori
        
        function obj = CoreDecisionReal3 (obj,closurePrices,volumes,vtresh,vlimit)
            
            %NOTE: controlla che le ultime chiusure siano concordi e poi
            %decide cosa fare
            
            v=volumes;
            %                 vl=20;
            %                 if length(v) < vl
            %                     vm=mean(v);
            %                 else
            %                     vm=mean(v(1:vl));
            %                 end
            %                 f=1.2;
            %                 vlimit=f*vm;
            
            %vtresh=20;
            %vlimit=400;
            
            
            p=closurePrices;
            bc = altiBassicontatore(p);
            
            %condizione sulle chiusure on-line 240min (deve essere 0 1)
            if bc(1,1) > 1 || v(1,1)> vlimit
                if v(1,1)< vtresh
                    obj.state = 1;
                else
                    obj.state = 0;
                end
            else
                obj.state = 1;
            end
            
        end
        
        
        
        %% decision REAL 4 a priori
        
        function obj = CoreDecisionReal4 (obj,closurePrices)
            
            %NOTE: controlla che le ultime chiusure siano concordi e poi
            %decide cosa fare
            
            p=closurePrices;
            bc = altiBassicontatore(p);
            
            %condizione sulle chiusure on-line 240min (deve essere 0 1)
            if bc(1,1) > 1
                obj.state = 0;
            else
                obj.state = 1;
            end
            
            
        end
        
        
        %%
        
        function obj = CoreLinearFlatTrend (obj,TimeSeriesExpert_11,closurePrices,limitRate1,limitRate2)
            
            %NOTE: usa la funzione linearRegression del TimeSiriesExpert
            %LOGICA: Prese in input le chiusure controlla il rate e il
            %segno della linear regression di tutto il campione e se sono
            %concordi a quelli degli ultimi n candelotti (default 5) indica un trend.
            
            closure1=closurePrices;
            
            [q0,res,rate1,type1] = TimeSeriesExpert_11.linearRegression (closure1);
            
            flatTrend1=0;
            flatTrend2=0;
            
            if rate1 <= limitRate1
                flatTrend1=1;
            end
            
            closure2=closurePrices(end-5:end);
            
            [q0,res,rate2,type2] = TimeSeriesExpert_11.linearRegression (closure2);
            
            
            if rate2 <= limitRate2
                flatTrend2=1;
            end
            
            if flatTrend1==1 && flatTrend2==1
                obj.state=1;     % 1 hai un trend piatto
            end
            
        end
        
        %%
        
        function obj = core_Algo_000_test (obj,closure)
            
            %NOTE: algoritmo di test per il bkt rispetto al demo
            %LOGICA: Se ho 2 candelotti dello dello stesso segno apro, e
            %vado in quella direzione
            
            candelotto1=sign(closure(end)-closure(end-1));
            candelotto2=sign(closure(end-1)-closure(end-2));
            c0=abs(candelotto1);
            
            if (c0>0) && (candelotto1 == candelotto2)
                obj.state=1;
                obj.suggestedDirection=candelotto1;
                obj.suggestedTP = 4;
                obj.suggestedSL = 4;
            else
                obj.state=0;
            end
            
            
        end
        
        
        
        %%
        
        function obj = core_Algo_002_leadlag (obj,closure,params,windowSize1,windowSize2,fluctLimit,wTP,maxSL)
            
            %NOTE:
            %LOGICA: fa 2 smoothing e quando si incrociano apre nella
            %direzione opposta dello smooth minore
            %
            
            % non uso i dati al minuto per le valutazioni dello
            % state
            closePrice=closure;
            
            a = (1/windowSize1)*ones(1,windowSize1);
            smoothClose1 = filter(a,1,closePrice);
            
            b = (1/windowSize2)*ones(1,windowSize2);
            smoothClose2 = filter(b,1,closePrice);
            fluctuations2=abs(closePrice-smoothClose2);
            devFluct2=std(fluctuations2(windowSize2:end));
            
            %             cla
            %             plot(closure,'ob')
            %             hold on
            %             plot(smoothClose1,'-b')
            %             plot(smoothClose2,'-r')
            
            newSmoothClose1=smoothClose1(end);
            newSmoothClose2=smoothClose2(end);
            
            oldSmoothClose1=params.get('smoothVal1');
            oldSmoothClose2=params.get('smoothVal2');
            
            oldDifference=oldSmoothClose1-oldSmoothClose2;
            newDifference=newSmoothClose1-newSmoothClose2;
            
            oldSign=sign(oldDifference);
            newSign=sign(newDifference);
            
            inversion=oldSign*newSign;
            
            if inversion <0 && devFluct2 > fluctLimit % I don't start if fluctuations are too small
                obj.state=1;
                obj.suggestedDirection=-newSign;
                volatility = min(floor(wTP*devFluct2),maxSL);
                obj.suggestedTP = volatility;
                obj.suggestedSL = volatility;
            else
                obj.state=0;
            end
            
            params.set('smoothVal1',smoothClose1(end));
            params.set('smoothVal2',smoothClose2(end));
            
        end
        
        
        %%
        function obj = core_Algo_003_slingShot(obj,opens, lows, highs, closure, params)
            
            actualPrice     = closure(end);
            setupBarOpen    = opens(end-1);                                % it uses only the last price at 30 min and the actual price at 1 min
            setupBarMax     = highs(end-1);
            setupBarMin     = lows(end-1);
            setupBarClose   = closure(end-1);
            
            dimension = 20;
            
            setupBarDirection = setupBarClose - setupBarOpen;
            entry_conditionLong  = params.get('entry_conditionLong');
            entry_conditionShort = params.get('entry_conditionShort');
            
            % entry long
            if (actualPrice < setupBarMin) && (setupBarDirection < - dimension)
                newSL = abs(actualPrice - setupBarClose);
                oldSL = params.get('stopLoss__');
                SL=max(newSL,oldSL);
                params.set('stopLoss__',SL);
                if (entry_conditionLong == 0)
                    obj.state=0;
                    params.set('entry_conditionLong',1);
                end
            end
            if (entry_conditionLong == 1) && (actualPrice > setupBarClose)
                obj.state=1;
                obj.suggestedDirection = - sign(setupBarDirection);
                obj.suggestedSL = params.get('stopLoss__');
                obj.suggestedTP = dimension/10;
            end
            
            % entry short
            if (actualPrice > setupBarMax) && (setupBarDirection > dimension)
                newSL = abs(actualPrice - setupBarClose);
                oldSL = params.get('stopLoss__');
                SL=max(newSL,oldSL);
                params.set('stopLoss__',SL);
                if (entry_conditionLong == 0)
                    obj.state=0;
                    params.set('entry_conditionLong',1);
                end
            end
            if (entry_conditionShort == 1) && (actualPrice < setupBarClose)
                obj.state=1;
                obj.suggestedDirection = - sign(setupBarDirection);
                obj.suggestedSL = params.get('stopLoss__');
                obj.suggestedTP = dimension/10;
            end
            
            
        end
        
        
        %%
        
        %%
        
        function obj = core_Algo_004_statTrend (obj,closure,params,windowSize1,windowSize2,timeSeriesProperties)
            
            %NOTE:
            %LOGICA: fa 2 smoothing e quando si incrociano apre se sono concordi
            %
            
            % non uso i dati al minuto per le valutazioni dello
            % state
            
            closePrice=closure;
            
            a = (1/windowSize1)*ones(1,windowSize1);
            smoothClose1 = filter(a,1,closePrice);
            %             fluctuations1=abs(closure-smoothClose1);
            %             devFluct1=std(fluctuations1(windowSize1:end));
            %             actualFluct1=closure(end)-smoothClose1(end);
            %             signDirection1=sign(actualFluct1);
            
            b = (1/windowSize2)*ones(1,windowSize2);
            smoothClose2 = filter(b,1,closePrice);
            fluctuations2=abs(closePrice-smoothClose2);
            meanFluct2=mean(fluctuations2(windowSize2:end));
            %             devFluct2=std(fluctuations2(windowSize2:end));
            %             actualFluct2=closure(end)-smoothClose2(end);
            %             signDirection2=sign(actualFluct2);
            
            gradient1=diff(smoothClose1);
            gradient2=diff(smoothClose2);
            
            newSmoothClose1=smoothClose1(end);
            newSmoothClose2=smoothClose2(end);
            newGradient1=gradient1(end);
            newGradient2=gradient2(end);
            
            oldSmoothClose1=params.get('smoothVal1');
            oldSmoothClose2=params.get('smoothVal2');
            oldGradient1=gradient1(end-1);
            oldGradient2=gradient2(end-1);
            
            oldDifference=oldSmoothClose1-oldSmoothClose2;
            newDifference=newSmoothClose1-newSmoothClose2;
            
            oldSign=sign(oldDifference);
            newSign=sign(newDifference);
            
            inversion=oldSign*newSign;
            newState=sign(newGradient1*newGradient2);
            oldState=sign(oldGradient1*oldGradient2);
            %             trend=newState+oldState;
            trendDirection=sign(newGradient2);
            
            Hurst         = timeSeriesProperties.HurstSmooth(end);
            gradientHurst = timeSeriesProperties.HurstDiff(end);
            
            %                         subplot(3,1,1)
            %                         cla
            %                         plot(closePrice,'ob')
            %                         hold on
            %                         plot(smoothClose1,'-b')
            %                         plot(smoothClose2,'-r')
            
            %             if inversion<0 && trend==2 && gradientHurst > 0
            if inversion<0 && gradientHurst > 0
                %             if inversion<0 && trend == 2 && Hurst > 0.5
                %             if inversion<0 && Hurst > 0.55 && gradientHurst > 0
                %             if abs(inversion)>0 && Hurst > 0 && abs(gradientHurst)>0    %test
                
                obj.state=1;
                obj.suggestedDirection=trendDirection;
                obj.suggestedTP=min(5*meanFluct2,100);
                obj.suggestedSL=min(5*meanFluct2,100);
            else
                obj.state=0;
            end
            
            params.set('smoothVal1',smoothClose1(end));
            params.set('smoothVal2',smoothClose2(end));
            
        end
        
        
        
        function obj = core_Algo_011_stocOsc(obj, low, high, closure, params,Kperiods, Dperiods)
            
            stosc = stochosc(high, low, closure,Kperiods,Dperiods); % 3,1 for AUDCAD
            FpK = stosc(:,1);
            
            obj.state=0;
            
            if (FpK(end) < 20 )
                
                params.set('previous_signal',1);
                
            elseif (FpK(end) > 80 )
                
                params.set('previous_signal',-1);
                
            else
                
                prev_signal=params.get('previous_signal');
                
                % if the signal moves from oversold/bought to stable + if there was a modest trend over the last 5 periods
                if(prev_signal~=0) && ( ( closure(end-5) - closure(end) ) / closure(end) * prev_signal > 0.002 )
                    
                    obj.state=1;
                    obj.suggestedDirection=prev_signal;
                    obj.suggestedTP=26;
                    obj.suggestedSL=26;
                    
                end
                
                params.set('previous_signal',0);
                
            end
            
            
        end
        
        function obj = core_Algo_016_doubleRepo(obj, low, high, closure, lastPriceMinute, params,windowSize, shift)
            
            closePrice=closure;
            minTrendLength = 8; %this is a parameter that can be modified
            
            a = (1/windowSize)*ones(1,windowSize);
            lead = filter(a,1,closePrice);
            
            shiftedlead = [ nan(shift,1); lead(1:end-shift) ];
            
            s = sign( closure((end-minTrendLength):end) - shiftedlead((end-minTrendLength):end) );
            s(s==0)=1;
            
            
            obj.state=0;
            
            timeAfterTrend=params.get('timeAfterTrend');
            trendLength = params.get('trendLength');
            strend = params.get('previous_signal');
            StartingTrendPrice = params.get('StartingTrendPrice');
            trigger1 = params.get('trigger1'); % first penetration
            trigger2 = params.get('trigger2'); % exit penetration
            
            if ( trigger1~=0 && timeAfterTrend>15 ) % if too long has passed after the first penetration, reset
                trigger1 = 0;
                trigger2 = 0;
                timeAfterTrend = 0;
                trendLength = 0;                
                params.set('trigger1',0);
                params.set('trigger2',0);
                params.set('timeAfterTrend',0);
                params.set('trendLength',0);
            end
            
            if (trigger1 == 0)
                
                % check if a trend is present for at least 'minTrendLength' periods
                if ( s(end) == s(end-1) )
                    
                    params.set('previous_signal',s(end));
                    trendLength = trendLength + 1;
                    params.set('trendLength',trendLength);
                    
                    if (trendLength == 1) % record the price when the trend starts
                        params.set('StartingTrendPrice',closure(end-1));
                    end
                    
                else % if the trend is finished, check how long was it and how big (in pips)
                    
                    if (trendLength >= minTrendLength && abs(closure(end-1)-StartingTrendPrice)> 50 )
                        
                        params.set('trigger1',1); % first penetration present
                        %params.set('timeAfterTrend',1);
                        
                    else % trend not long enough
                        
                        params.set('trendLength',0);
                        params.set('trigger1',0);
                        params.set('timeAfterTrend',0);
                        
                    end
                    
                end
                
                
            else % if trigger1 is on
                
                timeAfterTrend = timeAfterTrend + 1;
                params.set('timeAfterTrend',timeAfterTrend);
                
                if (s(end) == strend)
                    
                    params.set('trigger2',1); % exit penetration
                    
                end
                
                
                
                if trigger2
                    
                    if (s(end) == -strend) % second penetration!!
                        
                        if ( (closure(end) - StartingTrendPrice)*strend < 10 ) % if the current price is too close to the price at the start of the trend, don't open
                            
                            params.set('trigger1',0);
                            params.set('trigger2',0);
                            params.set('trendLength',0);
                            params.set('timeAfterTrend',0);
                            
                        else % if the trend is consistent, open
                            
                            obj.state = 1;
                            obj.suggestedDirection = -strend;
                            
                            if obj.suggestedDirection == 1
                                volatility = lastPriceMinute - min(low(end-timeAfterTrend:end)) ;
                            else
                                volatility = max(high(end-timeAfterTrend:end)) - lastPriceMinute ;
                            end
                            
                            obj.suggestedTP = max(min(volatility,50),5);
                            obj.suggestedSL = max(min(volatility,50),5);
                            
                            params.set('trigger1',0);
                            params.set('trigger2',0);
                            params.set('trendLength',0);
                            params.set('timeAfterTrend',0);
                            
                        end
                        
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
end
