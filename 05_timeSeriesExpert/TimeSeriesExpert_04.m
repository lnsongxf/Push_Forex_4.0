classdef TimeSeriesExpert4 < handle
    
    properties
        
        openV
        maxV
        minV
        closeV
        vol
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
        startMicroTrend
        rateMacroTrend
        rateMicroTrend
        typeMacroTrend
        typeMicroTrend
        qFitMacroTrend
        qUpMacroTrend
        indexMax
        positionMax
        lastM
        
    end
    
    methods
        
        function [obj]=readData(obj,data)
            
            obj.openV=data(:,1);
            obj.maxV=data(:,2);
            obj.minV=data(:,3);
            obj.closeV=data(:,4);
            obj.vol=data(:,5);
           
        end
        
        function [obj]=rescaleData(obj,actTimeScale,newTimeScale)
            
            
            if actTimeScale>newTimeScale
                h=msgbox('The data can not be rescaled','WARN','warn');
                waitfor(h)
                return
            end
            
            nRescale=newTimeScale/actTimeScale;
            
            o=obj.openV;
            M=obj.maxV;
            m=obj.minV;
            c=obj.closeV;
            v=obj.vol;
            
            oldL=length(o);
            newL=floor(oldL/nRescale);
                        
            clear obj.openV obj.maxV obj.minV obj.closeV obj.vol;
            
            obj.openV=o(nRescale:nRescale:(newL)*nRescale);
            obj.maxV=M(nRescale:nRescale:(newL)*nRescale);
            obj.minV=m(nRescale:nRescale:(newL)*nRescale);
            obj.closeV=c(nRescale:nRescale:(newL)*nRescale);
            
            vv=[newL,1];
            
            for i = 1:newL
                vv(i)=sum(v(((i-1)*nRescale+1):(nRescale*i)));
            end
            
            obj.vol=vv';
            
                        
                          
        end
        
        
        function [obj]=maxMinSearch(obj,type,rate,t0s,i,x1,yEnd_f1)
                       
            %% initialize
            
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
            
                        
            %% find distance and gap
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
                
            %% calculate drawdown

                %[~,~,drawDown] = find(dd);
                [~,~,index1] = find(q);
                
                index1=[index1;last];
                %display(index1);
                %display(index1);
                %[~,~,index2] = find(w);
                
                obj.positionMax=index1;
                obj.lastM=last;

                cla
                plot(price,'-b');
                hold on
                plot(index1,price(index1),'or');
                plot(x1,yEnd_f1,'-b');
                %plot(index2,price(index2),'og');
                

                
                
             %% save DD and RB  
             
%              obj.maxDD=max(drawDown);
%              obj.minDD=min(drawDown);
%              obj.aveDD=mean(drawDown);
             
%              obj.maxRB=max(rebound);
%              obj.minRB=min(rebound);
%              obj.aveRB=mean(rebound);
             

        end
        
        
        function [type,rate,err,indexStart,i]=linFitTrendRec(obj,actTimeScale,n,fun,inFit)
        
            %o=obj.openV;
            %M=obj.maxV;
            %m=obj.minV;
            c=obj.closeV;
            %v=obj.vol;

            inFit1=inFit;
            inFit2=inFit;
            
            l=length(c);
            err=zeros([l,2]);
            q0=zeros([l,2]);
            q0up=zeros([l,2]);
            rate=zeros([l,2]);
            type=zeros([l,2]);
            s=actTimeScale;
            t0s=zeros([l,1]);
            t0s(1,1)=1;
            t01=1;
            t02=1;
            tf=0;

            i=1;
            in=1;

            obj.lastM=1;
            
            while tf==0
                i=i+1;
                
                x1=(t01:s:i*s)';
                ct1=c(t01:s:i*s);
                [vEnd_f1, yEnd_f1, err1] = fit(n,x1,ct1,fun,inFit1);
                err(i,1)=err1;
                      
                
                x2=(t02:s:i*s)';
                ct2=c(t02:s:i*s);
                [vEnd_f2, ~, err2] = fit(n,x2,ct2,fun,inFit2);
                err(i,2)=err2;
                
                
                q0(in,1)=vEnd_f1(1,2);
                rate(in,1)=abs(vEnd_f1(1,1));
                type(in,1)=sign(vEnd_f1(1,1));
                inFit1=[type(in,1).*rate(in,1);vEnd_f1(1,2)];
                %inFit1=[vEnd_f1(1,2);type(in,1).*rate(in,1)];
                
                rate(:,2)=abs(vEnd_f2(1,1));
                type(:,2)=sign(vEnd_f2(1,1));
                inFit2=[type(in,2).*rate(in,2);vEnd_f2(1,2)];
                %inFit2=[vEnd_f2(1,2);type(in,2).*rate(in,2)];
                
                
                %display(i);
                %display(err1);
                %display(err2);
                
                
                
                
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

                
                if err2<0.5                
                    t02=i;
                    
%                     subplot(2,1,1)
%                     [r,~,~]=find(err(:,2)~=0);
%                     plot(r,err(r,2),'-r');
%                     hold on
                    
%                     subplot(2,1,2)
%                     plot(x2,ct2);
%                     hold on;
%                     plot(x2,yEnd_f2,'-g');  
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
                %obj.qDwMacroTrend

%                 display(obj.rateMacroTrend);
%                 display(obj.typeMacroTrend);
%                 display(obj.qFitMacroTrend);
%                 display(obj.qUpMacroTrend);
                
                %obj.startMicroTrend=t0s(indexStart,1);
                obj.rateMicroTrend=rate(indexStart,2);
                obj.typeMicroTrend=type(indexStart,2);
                
                
            end

          
            
        end
        
        
        
    end
    
end
