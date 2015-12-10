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
        
        function obj = CoreTest (obj,closure)
            
            %NOTE: algoritmo di test per il bkt rispetto al demo
            %LOGICA: Se ho 2 candelotti dello dello stesso segno apro, e
            %vado in quella direzione
            
            candelotto1=sign(closure(end)-closure(end-1));
            candelotto2=sign(closure(end-1)-closure(end-2));
            
            if candelotto1 == candelotto2
                obj.state=1;
                obj.suggestedDirection=candelotto1;
            else
                obj.state=0;
            end
            
            
        end
        
        
        %%
        
        function obj = core_Algo_002_leadlag (obj,closure,params)
            
            %NOTE:
            %LOGICA: fa 2 smoothing e quando si incrociano apre nella
            %direzione opposta dello smooth minore
            %
            
            % non uso i dati al minuto per le valutazioni dello
            % state
            closePrice=closure;
            
            windowSize1 = 2;
            a = (1/windowSize1)*ones(1,windowSize1);
            smoothClose1 = filter(a,1,closePrice);
            
            windowSize2 = 20;
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
            
            if inversion <0 && devFluct2 > 4 % I don't start if fluctuations are too small
                obj.state=1;
                obj.suggestedDirection=-newSign;
                obj.suggestedTP=7*devFluct2;
                obj.suggestedSL=7*devFluct2;
            else
                obj.state=0;
            end
            
            params.set('smoothVal1',smoothClose1(end));
            params.set('smoothVal2',smoothClose2(end));
            
        end
        
        %%
        
        function obj = core_Algo_004_statTrend (obj,closure,params,timeSeriesProperties)
            
            %NOTE:
            %LOGICA: fa 2 smoothing e quando si incrociano apre se sono concordi
            %
            
            % non uso i dati al minuto per le valutazioni dello
            % state
            
            closePrice=closure;
            
            windowSize1 = 10;
            a = (1/windowSize1)*ones(1,windowSize1);
            smoothClose1 = filter(a,1,closePrice);
            %             fluctuations1=abs(closure-smoothClose1);
            %             devFluct1=std(fluctuations1(windowSize1:end));
            %             actualFluct1=closure(end)-smoothClose1(end);
            %             signDirection1=sign(actualFluct1);
            
            windowSize2 = 50;
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
            trend=newState+oldState;
            trendDirection=sign(newGradient2);
            
            % Hurst         = timeSeriesProperties.HurstSmooth(end);
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
        
        function obj = core_Algo_011_stoc_oscillator (obj, low, high, closure, params)
            
            stosc = stochosc(high, low, closure, 3, 5);
            FpK = stosc(:,1);
            
            obj.state=0;
            
            if (FpK(end) < 20 )
                
                params.set('previous_signal',1);
                
            elseif (FpK(end) > 80 )
                
                params.set('previous_signal',-1);
                
            else
                
                prev_signal=params.get('previous_signal');
                
                if(prev_signal~=0)
                    
                    obj.state=1;
                    obj.suggestedDirection=prev_signal;
                    obj.suggestedTP=10;
                    obj.suggestedSL=10;
                    
                end
                
                params.set('previous_signal',0);
                
            end
            
            
        end
        
        
        
        
    end
    
end


