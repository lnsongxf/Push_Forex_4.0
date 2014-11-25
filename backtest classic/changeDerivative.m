function state = changeDerivative(gradient,lastOperation)

    if(sign(gradient(length(gradient))) == lastOperation*-1)
        state = 1;
    else
        state = 0;
    end
    

end

