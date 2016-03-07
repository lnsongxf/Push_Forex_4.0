function [newMaxArray,newMinArray] = RescaleMinAndMax(newTimeScale,maxArray,minArray,finalLength)

for i=1:finalLength
    
    newMaxArray(i) = max( maxArray((i-1)*newTimeScale +1 : i*newTimeScale ) );
    newMinArray(i) = min( minArray((i-1)*newTimeScale +1 : i*newTimeScale ) );
    
end

end