function [ state ] = fourierInBinary( data )
subplot(2,1,2);
appr    = fourierApp(data,3);
pause(1/10);
critPoints = getCritPoints(appr);
m = critPoints(1:2:end);
M = critPoints(2:2:end);
state = 1;
if (isempty(m) || isempty(M))
    state = 0;
else
    am = sort(m,'ascend');
    dm = sort(m,'descend');
    if sum(am == m) == length(m)
        aM = sort(M,'ascend');
        if sum(aM == M) == length(M)
            state = 0;
        end
    elseif sum(dm == m) == length(m)
        dM = sort(M,'descend');
        if sum(dM == M) == length(M)
            state = 0;
        end
    end
    
end

end