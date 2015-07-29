function [ nMax ] = iterativeMax( data,n )

    nMax = max(data);
    if n > 1
       for i = 2 : n
           nMax = max(data(data < nMax));
       end
    end
end

