classdef Performance < handle
    
    properties
        SR;
        dailyAveExReturns;
        pipsEarned;
        daysOperation;
        numOperations;
        RR;
        percExRetPos;
        percExRetNeg;
        percWeExRetPos;
        percWeExRetNeg;
        aveExRetPos;
        aveExRetNeg;
        minDD;
        maxDD;
        aveDD;
        minDDD;
        maxDDD;
        aveDDD;
    end
    
    
    methods
        
        %% Sharpe Ratio Calculation
        
        function obj=SharpeRatio(obj,outputBkt,freq,transCost)
            %a=(outputBkt(:,4))
            [~,~,r] = find(outputBkt(:,4).*outputBkt(:,6));
            [~,~,nOper] = find(outputBkt(:,1).*outputBkt(:,6));
            
            Returns=floor(r);
            
            ExReturns=Returns-transCost;
            daysOper=(nOper(end)-nOper(1))/(60/freq)/24;
            %daysOper=length(outputBkt)/(60/freq)/24;
            
            
            obj.daysOperation=daysOper;
            obj.pipsEarned=sum(ExReturns);
            obj.numOperations=length(Returns);
            
            if daysOper<1
                h=msgbox('insert a BKT longer than 1 day','WARN','warn');
                waitfor(h)
                return
            end
            
                                    
            %totExReturns=sum(ExReturns(:));
            %Profit=totExReturns/daysOper;
            
            dailyExReturns=zeros(floor(daysOper),1);
            pin=0;
            j=1;
            for i=1:length(Returns)
                t= (nOper(i)-pin)/(60/freq)/24;
                if t < 1
                    dailyExReturns(j)=dailyExReturns(j)+ExReturns(i);
                else
                    j=j+1;
                    pin=nOper(i);
                    dailyExReturns(j)=dailyExReturns(j)+ExReturns(i);
                end;
            end
            
            %display(dailyExReturns);
            %display(daysOper);
            %display(j);
            
            d=mean(dailyExReturns(1:j));
            display(d);
            obj.dailyAveExReturns=mean(dailyExReturns(:));
            dailyStdExReturns=std(dailyExReturns(:));
                      
            obj.SR=sqrt(512)*obj.dailyAveExReturns/dailyStdExReturns;
            
            plot(dailyExReturns,'-or');
            hold on
            l=zeros(size(dailyExReturns));
            plot(l);
        end
        
        
        %% Ricci Ratio Calculation
        
        function obj=RicciRatio(obj,outputBkt,transCost)
            
            [~,~,r] = find(outputBkt(:,4).*outputBkt(:,6));
            Returns=floor(r);
            ExReturns=Returns-transCost;
            
            [ip,~,~] = find(ExReturns>0);
            [in,~,~] = find(ExReturns<0);
            
            P=(ExReturns(ip));
            N=(ExReturns(in));
            
            aveP=mean(P);
            aveN=mean(N);
            
            %percentuali performance
            rP=length(P)*100/(length(P)+length(N));
            rN=length(N)*100/(length(P)+length(N));
            
            %percentuali pesate con il guadagno
            rwP=rP*aveP*100/(rP*aveP+rN*abs(aveN));
            rwN=abs(rN*aveN)*100/(rP*aveP+rN*abs(aveN));
                                    
            %Ricci Ratio: tra -1 e 1
            obj.RR=((aveP*rP)-abs((aveN*rN)))/((aveP*rP)+abs((aveN*rN)));
            
            obj.percExRetPos=rP;
            obj.percExRetNeg=rN;
            obj.percWeExRetPos=rwP;
            obj.percWeExRetNeg=rwN;
            obj.aveExRetPos=aveP;
            obj.aveExRetNeg=aveN;
            
        end
       
        
        
        %% DrawDown calculation
        
        function obj=DrawDown(obj,outputBkt)
                       
            [~,~,r] = find(outputBkt(:,4).*outputBkt(:,6));
            Returns=floor(r);
            
            %l=leverage;
            %iS=initialStock;
            
            %effecrive Stock
            %eS=iS*l; 
            %PL=eS+cumsum(Returns);
            
            PL=cumsum(Returns);
            plot(PL);
            
            highWatermark=zeros(size(PL));     
            p=zeros(size(PL));
            pp=zeros(size(PL));
            d=zeros(size(PL));
            dd=zeros(size(PL));
            
            
                for t=2:length(PL);
                    highWatermark(t)=max(highWatermark(t-1),PL(t));
                    %drawDown(t)=(1+highWatermark(t))/(1+PL(t))-1;
                    d(t)=highWatermark(t)-PL(t);
                    
                    if (d(t)==0)
                        p(t)=0;
                    else
                        p(t)=p(t-1)+1;
                    end
                end
                

                l=0;
                for i=1:length(d)
                    if d(i)==0
                        l=l+1;
                    end
                        if d(i)> dd(l,1)
                            dd(l,1)=d(i);
                        end                                     
                end
                [~,~,drawDown] = find(dd);
                %display(drawDown);
                
                k=0;
                for i=1:length(p)
                    if p(i)==0
                        k=k+1;
                    end
                        if p(i)> pp(k,1)
                            pp(k,1)=p(i);
                        end                                     
                end
                [~,~,drawDownDuration] = find(pp);
                %display(drawDownDuration);
                
                
            obj.maxDD=max(drawDown);
            obj.minDD=min(drawDown);
            obj.aveDD=mean(drawDown);
             
            obj.maxDDD=max(drawDownDuration);
            obj.minDDD=min(drawDownDuration);
            obj.aveDDD=mean(drawDownDuration);
            
        end
    
        
    end
    
    
    
end