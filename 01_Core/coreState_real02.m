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
        
        function obj = Algo_002_Ale (obj,closure)
            
            %NOTE: 
            %LOGICA: fa uno smoothing e se il prezzo e 2 dev sopra apre in
            %direzione del prezzo rispetto allo smooth
            
            smoothClose=smooth(closure,5);
            fluctuations=abs(closure-smoothClose);
            devFluct=std(fluctuations);
            actualFluct=closure(end)-smoothClose(end);
            signDirection=sign(actualFluct);
            
            if actualFluct >= 2*devFluct
                obj.state=1;
                obj.suggestedDirection=signDirection;
                obj.suggestedTP=6;
                obj.suggestedTP=3;
            else
                obj.state=0;
            end
            
            
            
            
            
        end
        
        
    end
    
end

        
