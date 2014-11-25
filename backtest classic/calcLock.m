function [ lock ] = calcLock( data, lastPos )

    [m1,m2] = movavg(data,5,20);
    lock = 1;
    if sign(m1(length(m1)) - m2(length(m2))) == lastPos*-1
       lock = 0; 
    end
    %hold off;
    %plot(data);
    %hold on;
    %plot(m1);
    %plot(m2);
end

