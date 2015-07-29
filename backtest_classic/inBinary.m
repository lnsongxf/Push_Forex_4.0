function [ state, low, up, stopLoss, noLoose,i ] = inBinary( data )

%{
c = csaps(1:length(data),data(),.8,1:length(data));
g = gradient(c);
p = [];
amp = [];
k = 0;
for i = 1 : length(data)-1
    if g(i)*g(i+1) < 0
        k = k + 1;
        p(k) = data(i);
        if k > 1
            amp(k-1) = abs(p(k) - p(k-1));
        end
    end
end
if k < i - 1
    k = k + 1;
    amp(k-1) = abs(data(length(data)) - p(k-1));
    p(k) = data(length(data));
end

found = 0;
iter = 0;
while (found == 0 && iter < 5)
    try
        iter = iter + 1;
        [app,cl,~] = kmeans(abs(amp),3);
        found = 1;
    catch Ex
        state = 0;
        low   = 0;
        up    = 0;
        if iter >= 5
            return
        end
    end
end
m = min(cl);
M = max(cl);
state = 1;
MAX_CL = cl==M;
%MIN_CL = cl==m;
%
zz = max(cl(cl < M));
m  = zz;
MIN_CL = cl==m;
%
media = mean(amp);
newState = 0;
for i = 0 : 2
    %newState = (amp(length(amp)-i)) > media ;
    newState = newState + MAX_CL(app(length(app)-i));
    if newState > 0
        state = 0;
        break;
    end
end

l = length(p);
up = max(p(l-3:l));
low= min(p(l-3:l));

%{
if state 
    for i = 3 : 10
        %if (MIN_CL(app(length(app)-i)) || MAX_CL(app(length(app)-i)))
        if amp(length(amp)-i) > media
            break;
        else
            up = max(p(l-i:l));
            low= min(p(l-i:l));
        end
    end
end
%}
actAmp = amp(length(amp));
%state = state && actAmp < mean(amp);
if state
   abc = 1; 
end

f1 = cl < M;
s21= cl(f1);
%f21 = s21 > m;
f21 = s21 < m;
s22 = s21(f21);

b1 = max(s22);
b2 = min(s22);
%stopLoss = mean([abs(b1);abs(b2)])/2*1.5;
stopLoss = b1/2*1.5;
%}
bc = altiBassi(data);
found = 1;
while found
    try
        [~,kkc] = kmeans(abs(bc(:,2)),3);
        found = 0;
    catch e
        display('riprova');
    end
end
kkc = sort(kkc);
actAmp = bc(length(bc)-3:length(bc),:);
state = 1;
if (sum(abs(actAmp (:,2)) > (kkc(3)-kkc(2))/2) > 0)
    state = 0;
    low = -1;
    up  = -1;
    i = length(data)-1;
else
    l = length(data);
    for i = 0 : 10
        up = max(data(l-i:l));
        low= min(data(l-i:l));
        if bc(length(bc)-i,2) > (kkc(3)-kkc(2))/2
            break;    
        end
    end
end

stopLoss = up-low;
noLoose = stopLoss/2;
end

