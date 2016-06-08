function [ w,l ] = simulate( dev, ntp, nsl )

takeProfit = dev*ntp;
stopLoss   = -dev*nsl;
w = 0;
l = 0;
for i = 1 : 100
finished = 0;
res = 0;    
    while finished == 0
        finished = 1;
        r = randn*dev;
        res = res + r;
        if res >= takeProfit
            w = w + 1;
        elseif res <= stopLoss
            l = l + 1;
        else
            finished = 0;
        end
    end
end

w = w/100;
l = l/100;

end



