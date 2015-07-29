function [ newposition ] = movavgalgo( data, actposition )
[m1,m2]=movavg (data, 5, 10);
[~,m3] =movavg (data, 20, 20);
if m1(length(m1)) < m2(length(m2)) && m2(length(m2)) < m3(length(m3))
   direction=-1;
elseif m1(length(m1)) > m2(length(m2)) && m2(length(m2)) > m3(length(m3))
    direction=1;
else
    direction = 0;
end
newposition = Position;
if direction == actposition.direction
    newposition.direction= actposition.direction;
elseif abs(direction) == 1
    newposition.direction = direction;
    newposition.openValue = data(length(data));
    actposition.closeValue= data(length(data));
else
    newposition.direction = 0;
    actposition.closeValue= data(length(data));
end

end

