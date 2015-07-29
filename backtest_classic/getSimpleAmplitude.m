function ret = getSimpleAmplitude(vettore)
    for i = 2 : length(vettore)
         ret(i-1) = vettore(i)-vettore(i-1);
    end
end