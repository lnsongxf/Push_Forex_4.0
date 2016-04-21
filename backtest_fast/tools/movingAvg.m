function mvavg=movingAvg(x, T)
% calculate moving average of x over T days. Expect T-1
% NaN in the beginning of the series

mvavg = zeros(size(x,1)-T+1, size(x, 2));

for i=0:T-1
    mvavg = mvavg + x(1+i:end-T+1+i, :);
end

mvavg = mvavg / T;

mvavg=[NaN*ones(T-1, size(x,2)); mvavg];

end