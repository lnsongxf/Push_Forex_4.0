%{  
    @param vettore1 il vettore degli ultimi n elementi di apertura
    @param vettore2 il vettore degli ultimi n elementi rappresentanti il valore massimo
    @param vettore3 il vettore degli ultimi n elementi rappresentanti il valore minimo
    @param vettore4 il vettore degli ultimi n elementi rappresentanti il valore di chiusura
    @param vettore5 il vettore degli ultimi n elementi rappresentanti il volume
%}
function [operationState,values,params] = lifeCicleNew(operationState, values,params)

    switch(abs(operationState.actualOperation))
        case 0
                [operationState, values, params] = operationZeroManager(operationState,values,params);
        case 1
            if(operationState.phase == 0)
                [operationState, values, params] = phaseZeroManager(operationState,values,params);
            elseif(operationState.phase == 1)
                [operationState, values, params] = phaseOneManager(operationState,values,params);
            end
           
    end
end
