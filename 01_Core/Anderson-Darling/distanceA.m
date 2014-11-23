function distanceA

k=0;
for n = 7 : 100
    k=k+1;
    [d]=errorP(n);
    Dd(k)=d;
end

plot(Dd);