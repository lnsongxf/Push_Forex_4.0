classdef Performance < handle
    
    properties
        SR;
        dailyAveExReturns;
        maxDD;
        maxDDD;   
    end
    
    
    methods
        function obj=SharpeRatio(obj,outputBkt,freq,transCost)
            %a=(outputBkt(:,4))
            Returns=floor(outputBkt(:,4));
            nOper=outputBkt(:,1);
            ExReturns=Returns-transCost;
            daysOper=(nOper(end)-nOper(1))/(60/freq)/24;
                                    
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
            
            
            obj.dailyAveExReturns=mean(dailyExReturns(:));
            dailyStdExReturns=std(dailyExReturns(:));
                      
            obj.SR=sqrt(512)*obj.dailyAveExReturns/dailyStdExReturns;
            
            plot(dailyExReturns,'-or');
            hold on
            l=zeros(size(dailyExReturns));
            plot(l);
        end
        
        function obj=DrawDown(obj,outputBkt,initialStock,leverage)
            Returns=floor(outputBkt(:,4));
            l=leverage;
            iS=initialStock;
            eS=iS*l; %effecrive Stock
            PL=eS+cumsum(Returns);
            plot(PL);
            
            
            
            highWatermark=zeros(size(PL));
            drawDown=zeros(size(PL));
            drawDownDuration=zeros(size(PL));
            
                for t=2:length(PL);
                    highWatermark(t)=max(highWatermark(t-1),PL(t));
                    drawDown(t)=(1+highWatermark(t))/(1+PL(t))-1;
                    if (drawDown(t)==0)
                        drawDownDuration(t)=0;
                    else
                        drawDownDuration(t)=drawDownDuration(t-1)+1;
                    end
                end
                
            obj.maxDD=max(drawDown)*eS;
            obj.maxDDD=max(drawDownDuration);
            
        end
    
    end
    
    
    
   
    
    
    
end