function [ newposition ] = tuo( data,stoploss, takeprofit, actposition )
newposition=Position;
d=data(length(data));
g=grad(data);
lastg=g(length(g));
prevg=g(length(g)-1);
if actposition.direction ==1
    if d > actposition.openvalue + takeprofit
        newposition.direction =0;
        newposition.closevalue=d;
    elseif d < actposition.openvalue - stoploss
        newposition.direction =0;
        newposition.closevalue=d;
    end
elseif actposition.direction ==-1
    if d < actposition.openvalue - takeprofit
        newposition.direction =0;
        newposition.closevalue=d;
    elseif d > actposition.openvalue+stoploss
        newposition.direction =0;
        newposition.closevalue=d;
    end
elseif act.position.direction ==0
    if lastg*prevg<0
        newposition.direction=sign(lastg);
        newposition.openvalue=d;        
    end
end

