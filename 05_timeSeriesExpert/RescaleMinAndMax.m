function [newMaxArray,newMinArray] = RescaleMinAndMax(newTimeScale,maxArray,minArray,finalLength)

newMaxArray = zeros(finalLength,1);
newMinArray = zeros(finalLength,1);

for i=1:finalLength
    
    newMaxArray(i,1) = max( maxArray((i-1)*newTimeScale +1 : i*newTimeScale ) );
    newMinArray(i,1) = min( minArray((i-1)*newTimeScale +1 : i*newTimeScale ) );
    
end

end