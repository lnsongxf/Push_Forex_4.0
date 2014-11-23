function [state,P] = anderson(data,Pa1,Pa2)

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
    
    P = 0;
    if (Ass >= 0.00 && Ass < 0.200);
        P = 1 - exp(-13.436 + 101.14*Ass - 223.73*Ass^2);
    elseif (Ass >= 0.200 && Ass < 0.340);
        P = 1 - exp(-8.318 + 42.796*Ass - 59.938*Ass^2);
    elseif (Ass >= 0.340 && Ass < 0.600);
        P = exp(0.9177 - 4.279*Ass - 1.38*Ass^2);
    elseif (Ass >= 0.600 && Ass <= 13);
        P = exp(1.2937 - 5.709*Ass + 0.0186*Ass^2);
    end
    
    if P > Pa1 && P < Pa2
        state=1;
    else
        state=0;
    end
    
    %display(Ass);
    %toc