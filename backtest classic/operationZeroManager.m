function [operationsState, values, params] = operationZeroManager( operationsState, values, params)
d = calcIndicator(params,values);
if(operationsState.lock == 1)
    if(sign(d) ~= sign(operationsState.lastOperation))
        operationsState.lock = 0;
        s = simulate(values,params);
        if(s > params.get('startValue'));
            operationsState.lastOperation = sign(d);
        else
            hVol = values.getHourVolumes;
            [~,mov1] = movavg(hVol,3,3);
            if(mov1(end) > mean(hVol) - 1/2*std(hVol));
                value                           = values.getLastValue;
                operationsState.actualOperation  = sign(d);
                params.set('openValue_',value.close);
                operationsState.phase           = 0;
            end
            clear hVol;
        end
    end
elseif(operationsState.lock == 0)
    s = simulate(values,params);
    value = values.getLastValue;
    prev  = values.getPrevValue;
    if(s > params.get('startValue'))
        operationsState.actualOperation  = sign(value.close - prev.close);
        params.set('openValue_',value.close);
        params.set('maxValue__',value.close);
        operationsState.phase   = 0;
        operationsState.counter = 0;
        if(value.close == 12265)
            display('trovato!');
        end
    end
end



end

