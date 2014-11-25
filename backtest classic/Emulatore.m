function [maxIncome] = Emulatore(range1,range2,range3,week,step)
%v = csvread('c:/Users/A-3/metatrader/experts/files/EURUSD60.csv'SGDJPY);
%vp = csvread('c:/Users/A-3/metatrader/experts/files/EURUSD1_03.csv');
global backup;

vp = backup(end-340*60-5*60*24*week:end-5*60*24*week*step,:);
l = length(vp);
rs= mod(l,60);
vp = vp(rs+1:end,:);
v = vp(1:60:length(vp),:);


for i = 1 : length(v)-2
    temp = max(vp((i-1)*60+1:i*60,2));
    v(i,2) = temp;
    temp = min(vp((i-1)*60+1:i*60,3));
    v(i,3) = temp;
end

global alfa;
global operation;
global coef;
global operazioni;
global andamento;
global memory;
global lock;
global value;
global valueTp;
global percTp;
global tp;
global start;
global maxValue;
global minValue;
global centralValue;
global tpFake;
global nl;
global maxPercTp;
global initPercTp;
global b;
global sl;

memoriaGuadagni = [];
memories        = [];

for index2      = 1 : length(range2)
    sl = range2(index2);
for index1      = 1 : length(range1)
    alfa = range1(index1);
for index3      = 1 : length(range3)
    perctTp     = range3(index3);

b = [];
maxPercTp  = .75;
initPercTp = .25;

%for alfa = 0 : .2 : 1

percTp = .1;
tp        = 100;
tpFake    = 0;
nl        = 20;
coef      = .3;
start     = .5;
%sl        = 25;
operation = 0;
operazioni = [0 0];
andamento = [];
guadagni  = [];
%alfa      = .5;
memory    = 0;
k = 1;

lock = 0;


for i = 100:(length(v)-120)
   v1 = v(i-99:i,1) ;
   v2 = v(i-99:i,2) ;
   v3 = v(i-99:i,3) ;
   v4 = v(i-99:i,4) ;
   %v5 = v(i-99:i,5) ;
   v5 = [4 5 6];
   for j = (i-1)*60+1:i*60
        value = vp(j,4);
        maxValue = vp(j,2);
        minValue = vp(j,3);
        v4(end) = value;
        memory = operation;
        %v4Minuto = vp(j-7999:j,4);
        %v2Minuto = vp(j-7999:j,2);
        %v3Minuto = vp(j-7999:j,3);
        lifeCicleNew(v1,v2,v3,v4,v5);
        if(sign(memory) > sign(operation) || sign(memory) < sign(operation))
            k = k+1;
            operazioni(k,2) = value;
            operazioni(k,1) = operation;
        end 
   end
%{
   if(mod(i,50) == 0 || i == length(v))
      t = 0;
       for j = 2 : length(operazioni)-1
           if(operazioni(j,1) == 0)
              t = t+1;
              differenza = (operazioni(j,2) - operazioni(j-1,2));
              guadagni(t) = differenza*sign(operazioni(j-1,1));
           end
       end
       plot(cumsum(guadagni),'b');
   end
   %}
end

       t = 0;
       for j = 2 : length(operazioni)
           if(operazioni(j,1) == 0)
              t = t+1;
              differenza = (operazioni(j,2) - operazioni(j-1,2));
              guadagni(t) = differenza*sign(operazioni(j-1,1));
           end
       end
       j = length(operazioni);
       if(abs(operazioni(j,1)) > 0)           
           t = t+1;
           differenza = (operazioni(j,2) - value);
           guadagni(t) = differenza*sign(operazioni(length(operazioni),2));
       end
       plot(cumsum(guadagni),'b');
       %if(isempty(memoriaGuadagni))
       %     memoriaGuadagni = [sum(guadagni) alfa sl];
       %else
       %    if(sum(guadagni) > memoriaGuadagni(:,1))    
       memoriaGuadagni(:,index1*index2*index3) = [sum(guadagni) alfa sl];
       %    end
       %end
       memories(:,index1*index2*index3) = sum(guadagni);
       
end
end
end

       g = gradient(memories);
       indice = 1;
       maxWin = 0;
       for j = 1 : length(g)-1;
          if(g(j)>= 0 && g(j+1)<=0)
              if(maxWin < memories(j+1))
                maxWin = memories(j+1);
                indice = j+1;
              end
          end
       end
       maxIncome = memoriaGuadagni(:,indice);