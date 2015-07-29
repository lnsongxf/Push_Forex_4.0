function  reticolo = Ising( N , iterazioni )
    dimensione = round(N^(1/2));
    reticolo = zeros(dimensione,dimensione);
    reticolo = initializeRet(reticolo);
    energia  = 
    i = 0;
    while(i < iterazioni)
        [x,y] = getRandomSpin(dimensione);
        
    end
end

function [x,y] = getRandSpin(dimensione)
    x = randi(dimensione,1);
    y = randi(dimensione,1);
end

function reticolo = initializeRet(reticolo)
    s = size(reticolo);
    dimX = s(1);
    dimY = s(2);
    for i = 1 : dimX
        for j = 1 : dimY
            reticolo(i,j) = randi(3,1) - 2;
        end
    end
end