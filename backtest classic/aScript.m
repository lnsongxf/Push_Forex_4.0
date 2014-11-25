k = 0;
wins = [];
dev = 30;
for z = 1 : 5
    k = 0;
    for i = .1:.1:3
        k = k+1;
        lVincite = 0;
        sommaVincite = 0;
        for j = 1 : 1000
            [w,l] = simulate(dev,i,z);
            lVincite = lVincite + 1;
            sommaVincite = sommaVincite + w;
            
        end
        wins(k,z) = sommaVincite/lVincite;
        display(strcat('wins   :',num2str(wins(k,z))));
        if (wins(k,z)/(1-wins(k,z)) > z/i)
            earn(k,z) = wins(k,z)*i*dev - (1-wins(k,z))*z*dev;
            display('eureka!');
            display(strcat('i    = ',num2str(i)));
            display(strcat('z    = ',num2str(z)));
            display(strcat('earn = ',num2str(earn)));
            a = 3;
        end
    end
end