function [guadagno,value1] = gradienteConiugato(range1,maxIter,epsilon,values)

%global sl;
%global alfa

delta = 100;
iter = -1;
value1 = range1(round(length(range1)/2));
app = 0;
firstIter = 0;
while((iter < maxIter && delta > app) || firstIter == 0)
    iter = iter + 1;
    
    tic;
    
    [v] = Emulatore(range1,value2,value3,week,step);
    alfa = v(2);
    delta = abs(value1 - alfa);
    value1 = alfa;
    
    
    toc;
    app = epsilon(reminder+1);
    
    if(iter >= 1)
        firstIter = 1;
    end
end
guadagno = v(1);
end