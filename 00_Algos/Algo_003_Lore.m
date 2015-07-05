function [oper, openValue, closeValue, stopLoss, noLoose, valueTp] = Algo_003_Lore(matrix)

%
% DESCRIPTION:
% -----------------------------------------------------------------------
% Algoritmo semplicissimo per far pratica
% Chiama 03: DecisionMaker_mean
% questa si calcola la media e deviaz standard di n dati storici e
% suggerisce compra/vendi se l'ultimo storico è sopra o sotto 1stdev dalla
% media


global      map;
% global      log;
persistent  counter;
persistent  countCycle;


openValue = 0;
closeValue= 0;
stopLoss  = 0;
noLoose   = 0;
valueTp   = 0;



cState = coreState_real02;
decMaker = DecisionMaker_mean;


if(isempty(map))
    map = containers.Map;
    counter = 0;
end

%display(countCycle);
if(isempty(countCycle) || countCycle == 0)
    countCycle = 1;
    operationState = OperationState;
    params         = Parameters;
    map('Algo_003_Lore') = RealAlgo(operationState,params);
    oper = 0;
    return;
end

ra = map('Algo_003_Lore');
remove(map,'Algo_003_Lore');

params         = ra.p;
operationState = ra.os;


%lows           = matrix(:,2);
%highs          = matrix(:,3);
chiusure        = matrix(:,4);
%volumi          = matrix(:,5);


state=1;           % in case of no coreState filter

if operationState.lock
    counter = counter + 1;
    if(counter > operationState.lockDuration )
        counter = 0;
        operationState.lock = 0;
    end
else
    if abs(operationState.actualOperation) > 0  
        % 02a
        % -------- takeProfitManager: close for TP or SL ------ %
        [operationState,~,params] = takeProfitManager(operationState,chiusure,params);
        
    else
        if abs(operationState.actualOperation) == 0
            if state
                
                % 02b
                % -------- takeProfitManager: define TP and SL ------ %
                TakeP=1;
                StopL=1;
                params.set('stopLoss__',StopL);
                params.set('noLoose___',TakeP);
                
                % 03b
                % -------- decMaker direction manager --------------- %
                [operationState,counter] = decMaker.decisionMeanSdev(chiusure,params,operationState);
                display('operazione aperta');
                
                                
            end
        end
    end
end

oper = operationState.actualOperation;

real_Algo = RealAlgo(operationState,params);
map('Algo_003_Lore')     = real_Algo;

openValue = params.get('openValue_');
closeValue= params.get('closeValue');
stopLoss  = params.get('stopLoss__');
noLoose   = params.get('noLoose___');
valueTp   = params.get('valueTp___');


clear real_Algo;
clear params;
clear operationState;
clear chiusure;
clear bc;
clear decMaker;
clear cState;

clear currValue;
clear index;
clear s;
clear ma;
clear state;
clear ao;
clear earn;
%clear w;
%clear l;
clear dev;

clear matrix;
clear ra;
%clear highs;
%clear lows;

display(oper)

end

