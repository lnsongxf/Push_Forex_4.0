function [array,statData] = normalizzaColonne( array, statData )
    
    dimensioni = size(array);
    colonne = dimensioni(2);

    if isempty(statData)
        for i = 1 : colonne
            media(i) = mean(array(:,i));
            dev(i)   = std(array(:,i));
        end
        statData = [media;dev];
    else
        for i = 1 : colonne
            media(i) = statData(1,i);
            dev(i)   = statData(2,i);
        end
    end
    
    for i = 1 : colonne
       array(:,i) = (array(:,i) - media(i))/dev(i);
    end

end

