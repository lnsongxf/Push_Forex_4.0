classdef TimeSeriesExpert < handle
    
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
        
        
        function [obj]=maxMinSearch(obj)
                       
            %% initialize
            
            price=obj.closeV;
                        
            plot(price);
            
            highWatermark=zeros(size(price));
            lowWatermark=zeros(size(price)); 
            p=zeros(size(price));
            pg=zeros(size(price));
            
            %pp=zeros(size(price));
            
            d=zeros(size(price));
            dg=zeros(size(price));
            
            dd=zeros(size(price));
            ddg=zeros(size(price));
            
            w=zeros(size(price));
            wg=zeros(size(price));
            
            q=zeros(size(price));
            qg=zeros(size(price));
            
            %% find distance and gap
            lowWatermark(1)=price(1);
                for t=2:length(price);
                    highWatermark(t)=max(highWatermark(t-1),price(t));
                    lowWatermark(t)=min(lowWatermark(t-1),price(t));
                    %drawDown(t)=(1+highWatermark(t))/(1+price(t))-1;
                    d(t)=highWatermark(t)-price(t);
                    dg(t)=price(t)-lowWatermark(t);
                                       
                    if (d(t)==0)
                        p(t)=0;
                    else
                        p(t)=p(t-1)+1;
                    end
                    
                    if (dg(t)==0)
                        pg(t)=0;
                    else
                        pg(t)=pg(t-1)+1;
                    end
                                       
                    
                end
                
            %% calculate drawdown
                
                l=0;
                for i=1:length(d)
                    if d(i)==0
                        l=l+1;
                        q(l,1)=i;
                    end
                        if d(i)> dd(l,1)
                            dd(l,1)=d(i);
                            w(l,1)=i;
                        end                                     
                end
                
                [~,~,drawDown] = find(dd);
                [~,~,index2] = find(w);
                %[~,~,index1] = find(q);
                %display(drawDown);
                              
                plot(price,'-b');
                hold on
                %plot(index1,price(index1),'or');
                plot(index2,price(index2),'og');
                
                
            %% calculate rebound (RB)
            
                lg=0;
                for i=1:length(dg)
                    if dg(i)==0
                        lg=lg+1;
                        qg(lg,1)=i;
                    end
                    if dg(i)>ddg(lg,1)
                        ddg(lg,1)=dg(i);
                        wg(lg,1)=i;
                    end
                end
                
                [~,~,rebound] = find(ddg);
                [~,~,index2g] = find(wg);
                %[~,~,index1g] = find(qg);
                display(rebound);
                
                plot(price,'-b');
                hold on
                %plot(index1g,price(index1g),'or');
                plot(index2g,price(index2g),'.r');
                
                
             %% save DD and RB  
             
             obj.maxDD=max(drawDown);
             obj.minDD=min(drawDown);
             obj.aveDD=mean(drawDown);
             
             obj.maxRB=max(rebound);
             obj.minRB=min(rebound);
             obj.aveRB=mean(rebound);
             
             
             
             
            
            %                 k=0;
%                 for i=1:length(p)
%                     if p(i)==0
%                         k=k+1;
%                     end
%                         if p(i)> pp(k,1)
%                             pp(k,1)=p(i);
%                         end                                     
%                 end
%                 [~,~,drawDownDuration] = find(pp);
                %display(drawDownDuration);
            
             
            %obj.maxDDD=max(drawDownDuration);
            %obj.minDDD=min(drawDownDuration);
            %obj.aveDDD=mean(drawDownDuration);
            
        end
        
        
        function [type,rate,err]=linFitTrendRec(obj,actTimeScale,n,fun,inFit)
        
            %o=obj.openV;
            %M=obj.maxV;
            %m=obj.minV;
            c=obj.closeV;
            %v=obj.vol;

            
            l=length(c);
            err=zeros([l,2]);
            s=actTimeScale;
            t01=1;
            t02=1;
            tf=0;
            
            i=1;  
            
            while tf==0
                i=i+1;
                
                x1=(t01:s:i*s)';
                ct1=c(t01:s:i*s);
                [vEnd_f1, yEnd_f1, err1] = fit(n,x1,ct1,fun,inFit);
                err(i,1)=err1;
                
                x2=(t02:s:i*s)';
                ct2=c(t02:s:i*s);
                [vEnd_f2, yEnd_f2, err2] = fit(n,x2,ct2,fun,inFit);
                err(i,2)=err2;
                
                                
                rate(:,1)=abs(vEnd_f1(1,2));
                type(:,1)=sign(vEnd_f1(1,2));
                rate(:,2)=abs(vEnd_f2(1,2));
                type(:,2)=sign(vEnd_f2(1,2));

                display(i);
                display(err1);
                display(err2);
                                
                if err1<0.8
                    %tf=1;                   
                    t01=i;
                    
                    subplot(2,1,1)
                    [r,~,~]=find(err(:,1)~=0);
                    plot(r,err(r,1),'ob');
                    hold on
                    
                    subplot(2,1,2)
                    plot(x1,ct1,'or');
                    hold on;
                    plot(x1,yEnd_f1,'-b');
                    
                    
                end
                
                if err2<0.25
                    %tf=1;                    
                    t02=i;
                    
                    subplot(2,1,1)
                    [r,~,~]=find(err(:,2)~=0);
                    plot(r,err(r,2),'-r');
                    hold on
                    
                    subplot(2,1,2)
                    plot(x2,ct2,'or');
                    hold on;
                    plot(x2,yEnd_f2,'-g');
                    
                    
                end

                
            end
               
            
            
            
            
            
            
            
            

        
        
        end
        
        
        
    end
    
end
