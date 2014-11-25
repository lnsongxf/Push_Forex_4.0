%{
    @param vettore1 il vettore degli ultimi n elementi di apertura
    @param vettore2 il vettore degli ultimi n elementi rappresentanti il valore massimo
    @param vettore3 il vettore degli ultimi n elementi rappresentanti il valore minimo
    @param vettore4 il vettore degli ultimi n elementi rappresentanti il valore di chiusura
    @param vettore5 il vettore degli ultimi n elementi rappresentanti il volume
%}
function [operationState,values,params] = lifeCicleNew_movavg(operationState, values,params)
%import java.lang.Thread;
%t = Thread;
vettore = values.getClosureVect;
if calcLock(vettore,operationState.lastOperation) == 0
    operationState.lock = 0;
end
%t.sleep(1000);
if operationState.lock == 0
    currValue = vettore(length(vettore));
    p = Position;
    p.direction = operationState.actualOperation;
    p = movavgalgo(vettore,p);
    %display(strcat('p.direction: ',num2str(p.direction)));
    %display(strcat('operationState.actualOperation :', num2str(operationState.actualOperation)));
    if (p.direction == 0 && abs(operationState.actualOperation) == 1)
        params.set('closeValue',currValue);
        operationState.lock = 1;
        operationState.lastOperation = operationState.actualOperation;
    elseif (abs(p.direction) == 1 && operationState.actualOperation == 0)
        params.set('openValue_',currValue);
    end
    
    operationState.actualOperation = p.direction;
    clear p;
    params.working = 1;
    
    clear t;
    
end
