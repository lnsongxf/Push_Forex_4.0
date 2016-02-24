function [min_return]=calculate_min_return(openingPrice, PriceArray, direction)

% the function calculates the minimum return touched during the operation

tempReturns = (PriceArray - openingPrice) * direction;

min_return =  min(tempReturns);


end