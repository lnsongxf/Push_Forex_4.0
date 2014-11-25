function [state, cluster,ret] = isClusterable(amp, clusterSize, clusterLimit)

state   = 0;
cluster = 0;
ret     = 0;
try
    [a,c] = kmeans(amp, clusterSize);    
    
    cluster = a(end);
    
    M = max(c);
    maxIndex = find(c >= M);
    
    found = 0;
    
    k = clusterSize;
    
    while (found == 0 && k >= clusterLimit)
        if cluster == maxIndex
           state    = 1;
           found    = 1;
           ret      = max(abs(amp(end) - c(maxIndex)),10);
        else
            k = k - 1;
            c = c(c < M);
            M = max(c);
            maxIndex = find(c >= M);
        end
        
    end
catch
    
end

clear a;
clear c;

end