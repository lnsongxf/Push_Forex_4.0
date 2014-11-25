function [ amp ] =vettoreOscillazioni(data,g)
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
end

