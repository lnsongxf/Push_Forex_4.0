function [params, operStates] = updateParamsOnMaxIncrease(params, operStates,value)

operStates.counter  = 0;
params.set('maxValue__',value);
params.set('percTp____',takeProfitFunction(params));
params.set('valueTp___',params.get('openValue_') + (params.get( 'maxValue__') - params.get('openValue_'))*params.get('percTp____'));


end

