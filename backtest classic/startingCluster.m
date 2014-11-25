function [ state, stopLoss, noLoose ] = startingCluster( data )

c = csaps(1:length(data),data,.8,1:length(data));
g = gradient(c);

p = [];
amp = [];
k = 0;
for i = 1 : length(data)-1
    if g(i)*g(i+1) < 0
        k = k + 1;
        p(k) = data(i);
        if k > 1
            amp(k-1) = p(k) - p(k-1);
        end
    end
end
if k < i - 1
    k = k + 1;
    amp(k-1) = data(length(data)) - p(k-1);
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
            
            if iter >= 5
                return
            end
        end
    end
m = min(cl);
M = max(cl);

MAX_CL = cl==M;
%MIN_CL = cl==m;
%
zz = max(cl(cl < M));
m  = zz;
MIN_CL = cl==m;

zz = max(cl(cl < m));
m  = zz;
MED_CL = cl==m;

%

actAmp = amp(length(amp));

newState = MIN_CL(app(length(app)));
%newState = newState + MAX_CL(app(length(app)));
state = newState > 0;
%state = actAmp > m;
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
%stopLoss = b1/2*1.5;
prevAmp = amp(length(amp)-1);

noLoose  = abs(prevAmp/2);
stopLoss = 2.5*noLoose;
end

