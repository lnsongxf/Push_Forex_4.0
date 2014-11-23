function [pnl,val]= fbacktest(data,v1,pt,st,dd)

iter=1; buy(iter)=0; sell(iter)=0; pnl=0; doubleup=1;

for i=1:length(data(:,2))
   
   %if long indicator gets turn on buy
   if data(i,2)<=-v1 && buy(iter)==0 && sell(iter)==0 
        buy(iter)=1;
        b1(iter)=data(i,1);
   end
    
   %if short indicator gets turned on sell
   if data(i,2)>v1 && sell(iter)==0 && buy(iter)==0 
        sell(iter)=1;
        s1(iter)=data(i,1);
   end

   %If you are long and hit a profit target, run this code
   if buy(iter)==1 && data(i,1)>b1(iter)+pt      
        b2(iter)=data(i,1); 
        pnl(iter)=doubleup*pt;
        iter=iter+1;
        buy(iter)=0;
        sell(iter)=0;
        doubleup=1;
    end
    
    %If you are long and hit a stop loss, run this code
    if buy(iter)==1 && data(i,1)<=b1(iter)-st
        
        if doubleup<=dd
        b1(iter)=(data(i,1)+doubleup*b1(iter))/(doubleup+1);
        doubleup=doubleup+1;         
        else
        b2(iter)=data(i,1); 
        pnl(iter)=-doubleup*st;
        iter=iter+1;
        buy(iter)=0;
        sell(iter)=0;
        doubleup=1;   
        end        
    end
   
    %If you are short, and hit a profit target, run this code
     if sell(iter)==1 && data(i,1)<s1(iter)-pt 
        s2(iter)=data(i,1); 
        pnl(iter)=doubleup*pt;
        iter=iter+1;
        buy(iter)=0;
        sell(iter)=0;
        doubleup=1;
     end
     
     %If you are short, and hit a stop loss, run this code
     if sell(iter)==1 && data(i,1)>=s1(iter)+st       
        if doubleup<=dd
          s1(iter)=(data(i,1)+doubleup*s1(iter))/(doubleup+1);
          doubleup=doubleup+1;
        else
        s2(iter)=data(i,1); 
        pnl(iter)=-doubleup*st;
        iter=iter+1;
        buy(iter)=0;
        sell(iter)=0;
        doubleup=1; 
        end       
     end
     
end

val(1)=sum(pnl);
val(2)=length(find(pnl>0))/length(pnl);
val(3)=mean(pnl)/std(pnl);
val(4)=length(pnl);
end