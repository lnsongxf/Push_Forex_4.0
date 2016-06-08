classdef coreState < handle
    
    properties
        state
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
        
        function obj= simulCore(obj,closurePrices,devMin,devMax)
            %function [ w, l, dev,med ] = simulCore( data, stopLoss, takeProfit )
            
            % calcola le ampiezze tra chiusure
            data=closurePrices;
            amp = getSimpleAmplitude(data);
            pd  = fitdist(amp','normal');

            
            %w = 0;
            %l = 0;
            
            %s = sign(pd.mu);
            
            %{
if (pd.mean == 0)
    w = 0;
    l = 1;
    dev = 1;
    med = 0;
    return;
end

if(nargin == 1)
    takeProfit = s*4;
    stopLoss   = -8*s;
elseif(nargin < 3)
    takeProfit = s*pd.std*stopLoss;
    stopLoss   = -3*pd.std*s;
else
    takeProfit = takeProfit*s*pd.std;
    stopLoss   = -stopLoss*pd.std*s;
end

for i = 1 : 100
finished = 0;
res = 0;
    while finished == 0
        finished = 1;
        rand = pd.random;
        res = res + rand;
        if (abs(res) >= abs(takeProfit) && sign(res) == sign(takeProfit))
            w = w + 1;
        elseif (abs(res) >= abs(stopLoss) && sign(res) == sign(stopLoss))
            l = l + 1;
        else
            finished = 0;
        end
    end
end

w = w/100;
l = l/100;
            %}
            obj.dev = pd.std;
            obj.med = pd.mean;
            
            if obj.dev > devMin && obj.dev < devMax 
                obj.state=1;
            else
                obj.state=0;
            end
            
                        
        end


        
        
        function obj= simulCore2(obj,massimiPrices,minimiPrices)
            
            %calcola le ampiezze delle fluttuazioni
            maxP=massimiPrices;
            minP=minimiPrices;
            a=maxP-minP;
            
            obj.dev=mean(a);
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
        
             
        
        
    end
    
    
    

    
    
    
end