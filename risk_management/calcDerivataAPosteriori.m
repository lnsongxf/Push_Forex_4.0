function colonna = calcDerivataAPosteriori( matrix, algoritmo )

    storico = algoritmo.history.matrixVal(:,4);
    delta   = algoritmo.deltaIndex;
    
    colonna = zeros(length(matrix),1);
    for i = 1 : length(matrix)
        index = matrix(i,1);
        subVettore = storico(index-delta+1:index);
        
        %calcolo della probabilità P
        %[~,P] = anderson(subVettore, .1,.5);
        %val = P;
        
        %calcolo della derivata
        %c = csaps(1:length(subVettore),subVettore,.7,1:length(subVettore));
        %g = gradient(c);
        %val = g(end);
        
        %calcolo di dev (e se interessa pure mu)
        %[~,~,dev,mu] = simul(subVettore);
        %val = dev;

        %Se servono altri cazzi chiedi e ti sarà dato
        
        colonna(i) = val;
    end

end

