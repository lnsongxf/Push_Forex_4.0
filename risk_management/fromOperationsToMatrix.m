function [ matrix ] = fromOperationsToMatrix( obj )
array = obj.array;
matrix = zeros(length(array),6);
for i = 1 : length(obj.array)
    o = obj.array{i};
    if(o.valueClose <= 0)
        continue;
    else
        matrix(i,1) = o.index;
        matrix(i,2) = o.stdDev;
        matrix(i,3) = o.deltaBinary;
        matrix(i,4) = o.earnCalculation;
        matrix(i,5) = o.type;
        matrix(i,6) = o.real;
    end
end

end

