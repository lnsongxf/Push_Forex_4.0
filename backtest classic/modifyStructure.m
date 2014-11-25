function modifyStructure(af)

global extended;
global lockCounter;


if(isempty(extended))
    extended = 0;
end

%{
if extended == 0
    
    if length(af.operations.array) >=10
        w = 0;
        l = 0;
        for i = 0 : 9
            if af.operations.array{end-1}.earnCalculation > 0
                w = w + 1;
            elseif af.operations.array{end-1}.earnCalculation < 0
                l = l + 1;
            end
        end
        if w < 2*l
            extended = 2;
            af.params.set('coeff_____',af.params.get('coeff_____')/2);
            af.deltaIndex = af.deltaIndex*2;
        end
    end
    if (length(af.operations.array) >=2 && extended == 0)
        lo = af.operations.array{end};
        po = af.operations.array{end-1};
        if lo.type == po.type*-1
            if (sign(lo.earnCalculation) == -1 && sign(po.earnCalculation) == -1)
                extended = 1;
                af.params.set('coeff_____',af.params.get('coeff_____')/2);
                af.deltaIndex = af.deltaIndex*2;
            end
        end
        
    end
elseif extended == 1
    lo = af.operations.array{end};
    if (sign(lo.earnCalculation) == 1)
        af.params.set('coeff_____',af.params.get('coeff_____')*2);
        af.deltaIndex = af.deltaIndex/2;
        extended = 0;
    end
elseif extended == 2
    w = 0;
    l = 0;
    for i = 0 : 9
        if af.operations.array{end-1}.earnCalculation > 0
            w = w + 1;
        elseif af.operations.array{end-1}.earnCalculation < 0
            l = l + 1;
        end
    end
    if w > 2*l
        extended = 0;
        af.params.set('coeff_____',af.params.get('coeff_____')*2);
        af.deltaIndex = af.deltaIndex/2;
    end
end

if length(af.operations.array) >=1
    lockCounter = max([0 (af.deltaIndex - (af.actIndex - af.operations.array{end}.index))])*af.history.extTimeInterval;
end
%}
end