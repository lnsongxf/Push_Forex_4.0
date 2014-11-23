classdef TimeSeriesExpert8 < handle
    
    properties
        
        state
        trend
        probability
        
        openV;
        maxV;
        minV;
        closeV;
        vol;
        
        openVrescaled;
        maxVrescaled;
        minVrescaled;
        closeVrescaled;
        volrescaled;
        
        maxDD
        minDD
        aveDD
        maxDDD
        minDDD
        aveDDD
        maxRB
        minRB
        aveRB
        
        startMacroTrend
        rateMacroTrend
        typeMacroTrend
        qFitMacroTrend
        qUpMacroTrend
        qDwMacroTrend
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
            
        end
        
        
        %%
        function [obj]=rescaleData(obj,data,actTimeScale,newTimeScale)
            
            
            if actTimeScale>newTimeScale
                h=msgbox('The data can not be rescaled','WARN','warn');
                waitfor(h)
                return
            end
            
            nRescale=newTimeScale/actTimeScale;
            
            [obj]=obj.readData(data);
            
            o=obj.openV;
            M=obj.maxV;
            m=obj.minV;
            c=obj.closeV;
            v=obj.vol;
            
            oldL=length(o);
            newL=floor(oldL/nRescale);
            
            clear obj.openV obj.maxV obj.minV obj.closeV obj.vol;
            
            obj.openVrescaled=o(nRescale:nRescale:(newL)*nRescale);
            obj.maxVrescaled=M(nRescale:nRescale:(newL)*nRescale);
            obj.minVrescaled=m(nRescale:nRescale:(newL)*nRescale);
            obj.closeVrescaled=c(nRescale:nRescale:(newL)*nRescale);
            
            vv=[newL,1];
            
            for i = 1:newL
                vv(i)=sum(v(((i-1)*nRescale+1):(nRescale*i)));
            end
            
            obj.vol=vv';
            
            
            
        end
        
        %%
        
        function plotBinary(obj,data,newTimeScale)
            
            % function for plotting the results of the binary expert: linFitTrendRec
            % hystorical data: matrix open/max/min/closure/volume/...
            % lengthData: number of hystorical data to consider
            
            s=newTimeScale;
            dataClosure=data(:,4);
            ltot=length(dataClosure);
            totDataMinutes=ltot*s;
            
            l=(1:s:totDataMinutes);
            
            figure(100);
            plot(l,dataClosure,'-b');
            hold on
            
            fit(:,1)= obj.typeMacroTrend.*obj.rateMacroTrend;
            fit(:,2)= obj.qFitMacroTrend;
            fitUp(:,1)= obj.typeMacroTrend.*obj.rateMacroTrend;
            fitUp(:,2)= obj.qUpMacroTrend;
            fitDw(:,1)= obj.typeMacroTrend.*obj.rateMacroTrend;
            fitDw(:,2)= obj.qDwMacroTrend;
            xi=obj.startMacroTrend;
            d=diff(obj.startMacroTrend);
            lengthTrends=[d; totDataMinutes-xi(end)];
            xfin=obj.startMacroTrend+lengthTrends;
            
            for i = 1: length(xi)
                x=xi(i):xfin(i);
                plot(x,linear1(fit(i,:),x));
                plot(x,linear1(fitUp(i,:),x),'-r');
                plot(x,linear1(fitDw(i,:),x),'-r');
                clear x
            end
            
        end
        
        
        %%
        
        
        function [obj]=maxMinSearch(obj,type,rate,t0s,i,x1,yEnd_f1)
            
            %%% initialize
            
            r=type*rate;
            price=obj.closeV;
            
            highWatermark=zeros(size(price));
            lowWatermark=zeros(size(price));
            %p=zeros(size(price));
            %pg=zeros(size(price));
            
            
            d=zeros(size(price));
            dg=zeros(size(price));
            
            %dd=zeros(size(price));
            %ddg=zeros(size(price));
            
            %w=zeros(size(price));
            q=zeros(size(price));
            
            %             q=obj.positionMax;
            %             k=obj.indexMax;
            
            
            %%% find distance and gap
            lowWatermark(1)=price(1);
            %m=1;
            k=1;
            
            [l,~,~] = find(t0s);
            t0s=t0s(l,1);
            
            for t=t0s(end,1)+2:i
                
                %display(t);
                highWatermark(t)=max(highWatermark(t-1),price(t)-r*(t-q(k,1)));
                lowWatermark(t)=min(lowWatermark(t-1),price(t));
                %drawDown(t)=(1+highWatermark(t))/(1+price(t))-1;
                d(t)=highWatermark(t)-price(t)+r*(t-q(k,1));
                dg(t)=price(t)-lowWatermark(t);
                
                %                 if d(t)> dd(m,1)
                %                     dd(m,1)=d(t);
                %                     m=m+1;
                %                 end
                
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
                        %display(last)
                        
                    elseif k~=1
                        last=q(k-1,1);
                    end
                end
                
                %                 if (d(t)<1)
                %                     p(t)=0;
                %                 else
                %                     p(t)=p(t-1)+1;
                %                 end
                
                
                %                 if (dg(t)<1)
                %                     pg(t)=0;
                %                 else
                %                     pg(t)=pg(t-1)+1;
                %                 end
                
                
            end
            
            %%% calculate drawdown
            
            %[~,~,drawDown] = find(dd);
            [~,~,index1] = find(q);
            
            index1=[index1;last];
            %display(index1);
            %display(index1);
            %[~,~,index2] = find(w);
            
            obj.positionMax=index1;
            obj.lastM=last;
            
            figure(10)
            cla
            plot(price,'-b');
            hold on
            plot(index1,price(index1),'or');
            plot(x1,yEnd_f1,'-b');
            %                 plot(x2,yEnd_f2,'-g');
            %                 plot(index2,price(index2),'og');
            
            
            
            
            %%% save DD and RB
            
            %              obj.maxDD=max(drawDown);
            %              obj.minDD=min(drawDown);
            %              obj.aveDD=mean(drawDown);
            
            %              obj.maxRB=max(rebound);
            %              obj.minRB=min(rebound);
            %              obj.aveRB=mean(rebound);
            
            
        end
        
        %%
        function [type,rate,err,indexStart,i]=linFitTrendRec(obj,data,actTimeScale,newTimeScale,n,fun,inFit)
            
            % this function creates ...
            %
            % to lunch the function:
            % inFit=[0 0];
            % [type,rate,err,indexStart,i]=expert.linFitTrendRec(dataShort(1:1000,:),1,1,@linear1,inFit)
            %
            % data                hystorical data open/max/min/closure/volume/...
            % actTimeScale        time scale to set default: 1 min
            % n                   number of series to fit default: 1
            % fun                 fitting function default: linear1
            % inFit               initialization parameters default: inFit=[0 0]
            
            [obj]=obj.readData(data);
            [obj]=rescaleData(obj,data,actTimeScale,newTimeScale);
            
            %o=obj.openV;
            %M=obj.maxV;
            %m=obj.minV;
            %c=obj.closeV;
            %v=obj.vol;
            
            c=obj.closeVrescaled;
            
            inFit1=inFit;
            
            l=length(c);
            err=zeros([l,2]);
            q0=zeros([l,2]);
            q0up=zeros([l,2]);
            rate=zeros([l,2]);
            type=zeros([l,2]);
            %s=actTimeScale;
            s=1;
            t0s=zeros([l,1]);
            t0s(1,1)=1;
            t01=1;
            tf=0;
            
            i=1;
            in=1;

            
            obj.lastM=1;
            
            
            while tf==0
                i=i+1;
                
                x1=(t01:s:i*s)';
                ct1=c(t01:s:i*s);
                [vEnd_f1, yEnd_f1, err1] = fit1(n,x1,ct1,fun,inFit1);
                err(i,1)=err1;
                

                
                q0(in,1)=vEnd_f1(1,2);
                rate(in,1)=abs(vEnd_f1(1,1));
                type(in,1)=sign(vEnd_f1(1,1));
                inFit1=[type(in,1).*rate(in,1);vEnd_f1(1,2)];
                %inFit1=[vEnd_f1(1,2);type(in,1).*rate(in,1)];
                

                if i>t01+2;
                    
                    [obj]=maxMinSearch(obj,type(in,1),rate(in,1),t0s,i,x1,yEnd_f1);
                    
                    
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
                        %display(vEup);
                        q0up(in,1)=vEup(1,2);
                    end
                    
                    plot(obj.positionMax,yFup,'-r');
                    
                end
                
                
                if err1<0.06
                    t01=i;
                    in=in+1;
                    t0s(in,1)=i;
                    
                    %display(t0s(:,1));
                    
                    %                     subplot(2,1,1)
                    %                     [r,~,~]=find(err(:,1)~=0);
                    %                     plot(r,err(r,1));
                    %                     hold on
                    
                    %                     subplot(2,1,2)
                    %                     plot(x1,ct1);
                    %                     hold on;
                    %                     plot(x1,yEnd_f1,'-b');
                end
                
               
                
                [indexStart,~,~]=find(t0s(:,1)~=0);
                
                %display(indexStart);
                %display(t0s(indexStart,1));
                %display(rate(indexStart,1));
                %display(type(indexStart,1));
                
                obj.startMacroTrend=t0s(indexStart,1);
                obj.rateMacroTrend=rate(indexStart,1);
                obj.typeMacroTrend=type(indexStart,1);
                obj.qFitMacroTrend=q0(indexStart,1);
                obj.qUpMacroTrend=q0up(indexStart,1);
                obj.qDwMacroTrend=obj.qFitMacroTrend-(obj.qUpMacroTrend-obj.qFitMacroTrend);
                
                display(obj.rateMacroTrend);
                display(obj.typeMacroTrend);
                display(obj.qFitMacroTrend);
                display(obj.qUpMacroTrend);
                display(obj.qDwMacroTrend);

                if i==length(c)
                    tf=1;
                end
                
                
            end
            
            
            
        end
        
        
        %% filtro Anderson - Darling
        % valuta la probabilità che n dati presi in input siano
        % distribuiti in maniera Gausssiana
        
        function [obj] = anderson(obj,data)
            
            %tic
            
            [obj]=obj.readData(data);
            
            %             maxValues=obj.closeV;
            %             minValues=obj.openV;
            %             fluct=abs(maxValues-minValues);
            
            fluct=abs(diff(obj.closeV));
            %
            %             display(obj.openV);
            %             display(obj.closeV);
            %             display(fluct);
            %
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
            
            
            %display(Ass);
            %toc
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
            [type,rate,err,indexStart,i]=obj.linFitTrendRec(scale1,20,@linear,inFit)
            
            
        end
        
        
        %%
        
        
        
        
        
        
        
    end
    
end
