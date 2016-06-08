function [operationState, valuesVector, params] = phaseOneManager(operationState, valuesVector, params)

value   = valuesVector.getLastValue;
value   = value.close;
%{
if(operationState.actualOperation == 1)
    termUp = value.high;
    termDw = value.low;
elseif(operationState.actualOperation == -1)
    termUp = value.low;
    termDw = value.high;
end
%}
%d = calcIndicator(params,valuesVector);
cond1 = abs( value - params.get('openValue_')) > abs(params.get('maxValue__') - params.get('openValue_')) ;
cond2 = sign(value - params.get('openValue_')) == sign(operationState.actualOperation);
cond3 = sign(value - params.get('valueTp___')) == sign(operationState.actualOperation)*-1;
%cond4 = sign(d) == sign(operationState.actualOperation)*-1;

if(cond1+cond2 == 2)
    operationState = params.updateParamsMaxIncrease(operationState, value);
elseif(cond3)
    operationState = params.updateParamsOnTakeProfit(operationState);
else
    operationState = params.updateParamsCounterIncrease(operationState);
end

end