classdef TimeSeriesExpert_11 < handle
    
    properties
        
        state
        trend
        probability
        
        openV;
        maxV;
        minV;
        closeV;
        vol;
        openD;
        
        openVrescaled;
        maxVrescaled;
        minVrescaled;
        closeVrescaled;
        volrescaled;
        openDrescaled;
        
        maxDD
        minDD
        aveDD
        maxDDD
        minDDD
        aveDDD
        maxRB
        minRB
        aveRB
        
        startTrend
        rateTrend
        typeTrend
        qFitTrend
        qUpTrend
        qDwTrend
        
        Trend1mins
        Trend5mins
        Trend10mins
        Trend30mins
        Trend60mins
        Trend240mins
        Trend1440mins
        
        indexMax
        positionMax
        lastM
        
    end
    
    methods
        
        
        %%
        function [obj]=readData(obj,data)
            
            obj.openV=data(:,1);
            obj.maxV=data(:,2);
            obj.minV=data(:,3);
            obj.closeV=data(:,4);
            obj.vol=data(:,5);
            obj.openD=data(:,6);
            
        end
        
        
        %%
        function [obj]=rescaleData(obj,outputHyst,actTimeScale,newTimeScale)
            
            
            if actTimeScale>newTimeScale
                h=msgbox('The data can not be rescaled','WARN','warn');
                waitfor(h)
                return
            end
            
            nRescale=newTimeScale/actTimeScale;
            
            [obj]=obj.readData(outputHyst);
            
            o=obj.openV;
            M=obj.maxV;
            m=obj.minV;
            c=obj.closeV;
            v=obj.vol;
            od=obj.openD;
            
            oldL=length(o);
            newL=floor(oldL/nRescale);
            
            clear obj.openV obj.maxV obj.minV obj.closeV obj.vol;
            
            obj.openVrescaled=o(nRescale:nRescale:(newL)*nRescale);
            obj.maxVrescaled=M(nRescale:nRescale:(newL)*nRescale);
            obj.minVrescaled=m(nRescale:nRescale:(newL)*nRescale);
            obj.closeVrescaled=c(nRescale:nRescale:(newL)*nRescale);
            obj.openDrescaled=od(nRescale:nRescale:(newL)*nRescale);
            
            vv=[newL,1];
            
            for i = 1:newL
                vv(i)=sum(v(((i-1)*nRescale+1):(nRescale*i)));
            end
            
            obj.volrescaled=vv';
            
            
            
        end
        
        %%
        
        function plotBinary(obj)
            
            % function for plotting the results of the binary expert: linFitTrendRec
            % hystorical data: matrix open/max/min/closure/volume/...
            % lengthData: number of hystorical data to consider
            
            %dataClosure=obj.closeVrescaled;
            dataClosure=obj.closeV;
            l=length(dataClosure);
            
            
            figure(100);
            plot(dataClosure,'-b');
            hold on
            
            fit(:,1)= obj.typeTrend.*obj.rateTrend;
            fit(:,2)= obj.qFitTrend;
            fitUp(:,1)= obj.typeTrend.*obj.rateTrend;
            fitUp(:,2)= obj.qUpTrend;
            fitDw(:,1)= obj.typeTrend.*obj.rateTrend;
            fitDw(:,2)= obj.qDwTrend;
            xi=obj.startTrend;
            d=diff(obj.startTrend);
            lengthTrends=[d; l-xi(end)];
            xfin=obj.startTrend+lengthTrends;
            
            for i = 1: length(xi)
                x=xi(i):xfin(i);
                plot(x,linear1(fit(i,:),x));
                plot(x,linear1(fitUp(i,:),x),'-r');
                plot(x,linear1(fitDw(i,:),x),'-r');
                clear x
            end
            
        end
        
              
        %%
        function [obj]=MultidimBinary(obj,data,timeScales)
            
            % define the timescale to use
            %timeScales=[5,30];
            %timeScales=[1,5,10,30,60,240,1440];
            
            tic
            n=1;
            actTimeScale=1;
            
            [~,~,v1]=find(timeScales==1);
            [~,~,v5]=find(timeScales==5);
            [~,~,v10]=find(timeScales==10);
            [~,~,v30]=find(timeScales==30);
            [~,~,v60]=find(timeScales==60);
            [~,~,v240]=find(timeScales==240);
            [~,~,v1440]=find(timeScales==1440);
            
            if v1
                % binary on 1 minute scale
                newTimeScale=1;
                inFit=[12500 0];
                [obj]=obj.linFitTrendRec(data,actTimeScale,newTimeScale,n,@linear1,inFit);
                
                obj.Trend1mins(:,1)=obj.startTrend;
                obj.Trend1mins(:,2)=obj.rateTrend;
                obj.Trend1mins(:,3)=obj.typeTrend;
                obj.Trend1mins(:,4)=obj.qFitTrend;
                obj.Trend1mins(:,5)=obj.qUpTrend;
                obj.Trend1mins(:,6)=obj.qDwTrend;
                
                plotBinary(obj)
                hold on
            end
            
            if v5
                % binary on 5 minutes scale
                newTimeScale=5;
                inFit=[12500 0];
                [obj]=obj.linFitTrendRec(data,actTimeScale,newTimeScale,n,@linear1,inFit);
                obj.startTrend;
                obj.Trend5mins;
                obj.Trend5mins(:,1)=obj.startTrend;
                obj.Trend5mins(:,2)=obj.rateTrend;
                obj.Trend5mins(:,3)=obj.typeTrend;
                obj.Trend5mins(:,4)=obj.qFitTrend;
                obj.Trend5mins(:,5)=obj.qUpTrend;
                obj.Trend5mins(:,6)=obj.qDwTrend;
                
                plotBinary(obj);
                hold on
            end
            
            if v10
                % binary on 10 minutes scale
                newTimeScale=10;
                inFit=[0 0];
                [obj]=obj.linFitTrendRec(data,actTimeScale,newTimeScale,n,@linear1,inFit);
                
                obj.Trend10mins(:,1)=obj.startTrend;
                obj.Trend10mins(:,2)=obj.rateTrend;
                obj.Trend10mins(:,3)=obj.typeTrend;
                obj.Trend10mins(:,4)=obj.qFitTrend;
                obj.Trend10mins(:,5)=obj.qUpTrend;
                obj.Trend10mins(:,6)=obj.qDwTrend;
                
                plotBinary(obj);
                hold on
            end
            
            if v30
                % binary on 30 minutes scale
                newTimeScale=30;
                inFit=[0 0];
                [obj]=obj.linFitTrendRec(data,actTimeScale,newTimeScale,n,@linear1,inFit);
                
                obj.Trend30mins(:,1)=obj.startTrend;
                obj.Trend30mins(:,2)=obj.rateTrend;
                obj.Trend30mins(:,3)=obj.typeTrend;
                obj.Trend30mins(:,4)=obj.qFitTrend;
                obj.Trend30mins(:,5)=obj.qUpTrend;
                obj.Trend30mins(:,6)=obj.qDwTrend;
                
                plotBinary(obj)
                hold on
            end
            
            if v60
                % binary on 60 minutes scale (1 hour)
                newTimeScale=60;
                inFit=[0 0];
                [obj]=obj.linFitTrendRec(data,actTimeScale,newTimeScale,n,@linear1,inFit);
                
                obj.Trend60mins(:,1)=obj.startTrend;
                obj.Trend60mins(:,2)=obj.rateTrend;
                obj.Trend60mins(:,3)=obj.typeTrend;
                obj.Trend60mins(:,4)=obj.qFitTrend;
                obj.Trend60mins(:,5)=obj.qUpTrend;
                obj.Trend60mins(:,6)=obj.qDwTrend;
                
                plotBinary(obj)
                hold on
            end
            
            if v240
                % binary on 240 minutes scale (4 hours)
                newTimeScale=240;
                inFit=[0 0];
                [obj]=obj.linFitTrendRec(data,actTimeScale,newTimeScale,n,@linear1,inFit);
                
                obj.Trend240mins(:,1)=obj.startTrend;
                obj.Trend240mins(:,2)=obj.rateTrend;
                obj.Trend240mins(:,3)=obj.typeTrend;
                obj.Trend240mins(:,4)=obj.qFitTrend;
                obj.Trend240mins(:,5)=obj.qUpTrend;
                obj.Trend240mins(:,6)=obj.qDwTrend;
                
                plotBinary(obj)
                hold on
            end
            
            
            if v1440
                % binary on 1440 minutes scale (1 day)
                newTimeScale=1440;
                inFit=[0 0];
                [obj]=obj.linFitTrendRec(data,actTimeScale,newTimeScale,n,@linear1,inFit);
                
                obj.Trend1440mins(:,1)=obj.startTrend;
                obj.Trend1440mins(:,2)=obj.rateTrend;
                obj.Trend1440mins(:,3)=obj.typeTrend;
                obj.Trend1440mins(:,4)=obj.qFitTrend;
                obj.Trend1440mins(:,5)=obj.qUpTrend;
                obj.Trend1440mins(:,6)=obj.qDwTrend;
                
                plotBinary(obj)
            end
            
            toc
            
            
        end
        
        
        %%
        function [obj]=linFitTrendRec(obj,data,actTimeScale,newTimeScale,n,fun,inFit)
          
            % DESCRIPTION:
            % -------------------------------------------------------------
            % This function allows to create a binary calculating trends
            % using a linear regression of the calculated price
            % maximum/minimum values.
            % 
            %
            % INPUT parameters:
            % -------------------------------------------------------------
            % data          ... hystorical data open/max/min/closure/volume
            %                   ecc...
            % actTimeScale  ... time scale to set default: 1 min
            % n             ... number of points of G(r)
            % fun           ... fitting function default: linear1
            % inFit         ... initialization FIT parameters default:
            %                   inFit=[0 0]
            %
            % OUTPUT parameters:
            % -------------------------------------------------------------
            % 
            %
            % EXAMPLE of use:
            % -------------------------------------------------------------
            % inFit=[12500 0]; [type,rate,err,indexStart,i]=expert.linFitTrendRec(data(1:5000,:),1,10,1,@linear1,inFit)
            %
            
            [obj]=obj.readData(data);
            [obj]=rescaleData(obj,data,actTimeScale,newTimeScale);

            c=obj.closeVrescaled;

            nRescale=newTimeScale/actTimeScale;
            
            s=1;
            inFit1=inFit;
            
            l=length(c);
            err=zeros([l,2]);
            q0=zeros([l,2]);
            q0up=zeros([l,2]);
            rate=zeros([l,2]);
            type=zeros([l,2]);
            t0s=zeros([l,1]);
            t0s(1,1)=1;
            t01=1;
            tf=0;
            i=0;
            in=1;
            obj.lastM=1;
            temperr1=1000000;
            
            while tf==0
                i=i+1;
                x1=((t01):s:i*s)';
                ct1=c(t01:1:i);
                [vEnd_f1, yEnd_f1, err1] = fit1(n,x1,ct1,fun,inFit1);
                if x1(end)-x1(1)<5
                    err1=1;
                end
                err(i,1)=err1;
                
                q0(in,1)=vEnd_f1(1,2);
                rate(in,1)=abs(vEnd_f1(1,1));
                type(in,1)=sign(vEnd_f1(1,1));
                inFit1=[type(in,1).*rate(in,1),vEnd_f1(1,2)];
                
                if i>t01+2;
                    
                    [obj]=maxMinSearch(obj,c,type(in,1),rate(in,1),t0s,i,x1,yEnd_f1);
                    
                    % binary maker
                    m0=type(in,1).*rate(in,1);
                    inFitBinary=zeros(2,1);
                    inFitBinary(1,1)=m0;
                    inFitBinary(2,1)=vEnd_f1(1,2);
                    
                    
                    vUp=abs(0.01*inFitBinary(1,1));
                    
                    vin=  [inFitBinary(1,1)-vUp inFitBinary(2,1)-0.99*inFitBinary(2,1)];
                    vfin= [inFitBinary(1,1)+vUp inFitBinary(2,1)+0.99*inFitBinary(2,1)];
                    
                    if length(obj.positionMax)>1
                        [vEup, yFup] = fitlsq(n,obj.positionMax,c(obj.positionMax),fun,inFitBinary,vin,vfin,m0);
                        q0up(in,1)=vEup(1,2);
                    else
                        yFup=1;
                    end
                    
                    plot(obj.positionMax,yFup,'-r');
                    
                end
                                  
                if err1<0.06 && err1>temperr1
                    t01=i;
                    in=in+1;
                    t0s(in,1)=i;
                end
                temperr1=err1;
                    
                [indexStart,~,~]=find(t0s(:,1)~=0);
                
                obj.startTrend=t0s(indexStart,1)*nRescale;
                obj.rateTrend=rate(indexStart,1)/nRescale;
                obj.typeTrend=type(indexStart,1);
                
                obj.qFitTrend=q0(indexStart,1);
                obj.qUpTrend=q0up(indexStart,1);
                obj.qDwTrend=obj.qFitTrend-(obj.qUpTrend-obj.qFitTrend);

                if i==length(c)
                    tf=1;
                end
                
                
            end
            
            
            
        end
        
        
        %% 
        function [obj]=maxMinSearch(obj,closure,type,rate,t0s,i,x1,yEnd_f1)
            
            %%% initialize
            
            r=type*rate;
            price=closure;
            
            highWatermark=zeros(size(price));
            lowWatermark=zeros(size(price));
            d=zeros(size(price));
            dg=zeros(size(price));
            q=zeros(size(price));
            
            %%% find distance and gap
            lowWatermark(1)=price(1);
            k=1;
            
            [l,~,~] = find(t0s);
            t0s=t0s(l,1);
            
            for t=t0s(end,1)+2:i

                highWatermark(t)=max(highWatermark(t-1),price(t)-r*(t-q(k,1)));
                lowWatermark(t)=min(lowWatermark(t-1),price(t));
                d(t)=highWatermark(t)-price(t)+r*(t-q(k,1));
                dg(t)=price(t)-lowWatermark(t);
                
                last=obj.lastM;
                ind=t-(t0s(end,1)+1);
                
                if abs(d(t))<1
                    if k>1 && q(k-1,1)~=t && price(t)> yEnd_f1(ind)
                        q(k,1)=t;
                        k=k+1;
                        
                    elseif k==1 && price(t)> yEnd_f1(ind)
                        q(k,1)=t;
                        k=k+1;
                        
                    elseif k>1 && q(k-1,1)==(t-1)
                        q(k-1,1)=t;
                    end
                end
                
                if t==i
                    if k==1 && abs(d(t))>1
                        last=1;
                        q(k,1)=last;
                        k=k+1;
                        
                    elseif k>1 && abs(d(t))>1
                        q(k,1)=last;
                        
                    elseif k~=1
                        last=q(k-1,1);
                    end
                end
                
            end
            
            %%% calculate drawdown
            
            [~,~,index1] = find(q);
            
            index1=[index1;last];

            obj.positionMax=index1;
            obj.lastM=last;
            
            
            % uncomment to plot the price with the binary
            figure(1)
            cla
            plot(price,'-b');
            hold on
            plot(index1,price(index1),'or');
            plot(x1,yEnd_f1,'-b');            
        end
        
        
        %%         
        function [obj] = anderson(obj,data)
            
            % filtro Anderson - Darling
            % valuta la probabilità che n dati presi in input siano
            % distribuiti in maniera Gausssiana

            [obj]=obj.readData(data);
            
            fluct=abs(diff(obj.closeV));
            
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
            
            obj.probability = 0;
            if (Ass >= 0.00 && Ass < 0.200);
                obj.probability = 1 - exp(-13.436 + 101.14*Ass - 223.73*Ass^2);
            elseif (Ass >= 0.200 && Ass < 0.340);
                obj.probability = 1 - exp(-8.318 + 42.796*Ass - 59.938*Ass^2);
            elseif (Ass >= 0.340 && Ass < 0.600);
                obj.probability = exp(0.9177 - 4.279*Ass - 1.38*Ass^2);
            elseif (Ass >= 0.600 && Ass <= 13);
                obj.probability = exp(1.2937 - 5.709*Ass + 0.0186*Ass^2);
            end
            
            figure(3)
            h  = hist(fluctS,5);
            hx = (min(fluct(:)):(max(fluct(:))-min(fluct(:)))/4:max(fluct(:)));
            plot(hx,h,'-ob');

        end
        
        
        %%        
        function obj = trendAnderson (obj,data)
            
            obj = obj.anderson(data);
            
            scale1 = 1;
            scale2 = 2;
            
            
            figure(1)
            plot(obj.closeV,'-ob');
            
            PshortScaleTrend=obj.probability;
            
            display('probability short scale');
            display(PshortScaleTrend);
            
            obj = obj.rescaleData(data,scale1,scale2);
            
            newdata(:,1)=obj.openV;
            newdata(:,2)=obj.maxV;
            newdata(:,3)=obj.maxV;
            newdata(:,4)=obj.closeV;
            newdata(:,5)=obj.vol;
            
            figure(2)
            plot(newdata(:,4),'-or');
            
            obj = obj.anderson(newdata);
            
            PlongScaleTrend=obj.probability;
            
            display('probability long scale');
            display(PlongScaleTrend);
            
            
            inFit=[0,mean(obj.closeV(:))];
            [~,~,~,~,~]=obj.linFitTrendRec(scale1,20,@linear,inFit);
            
            
        end
        

        %%
        
        function [obj,type,rate,q0,res] = linearRegression(obj,closure)
            
            %
            % DESCRIPTION:
            % -------------------------------------------------------------
            % This function calculate the linear regrssion of a vector of
            % values
            %
            % INPUT parameters:
            % -------------------------------------------------------------
            % closure       ... vector of closure values
            %
            % OUTPUT parameters:
            % -------------------------------------------------------------
            % type          ... sign of the linear regression slope
            % rate          ... slope of the linear regression
            % q0            ... coefficent of the linear regression
            % res           ... residuals
            %
            % EXAMPLE of use:
            % -------------------------------------------------------------
            % objname=TimeSeriesExpert_10;  
            % [objname,type,rate,q0,res]=objname.linearRegression(closurePrices);
            %
            
            global inFit1
            
            if(isempty(inFit1))
                inFit1=[0 0];
            end
            
            n=1;
            x1=(1:length(closure))';
            
            [vEnd_f1,~, err1] = fit1(n,x1,closure,@linear1,inFit1);
            
            
            res=err1;
            q0=vEnd_f1(1,2);
            rate=abs(vEnd_f1(1,1));
            type=sign(vEnd_f1(1,1));
            inFit1=[type.*rate;vEnd_f1(1,2)];
            
            
        end
        
        %%
        
        
        
        
        
        
    end
    
end
