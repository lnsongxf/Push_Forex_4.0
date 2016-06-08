function ret = getAmplitude(vettore)
    smooth = csaps(1:length(vettore),vettore,.3,1:.1:length(vettore));
    g      = gradient(smooth);
    k = 0;
    
    for i = 2 : length(g)
         if(g(i-1)*g(i) < 0)
            k = k+1;
            mem(k) = smooth(i);
         end
    end
    for i = 2 : length(mem)
       ret(i) = mem(i-1) - mem(i); 
    end
end