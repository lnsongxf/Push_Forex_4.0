function [oper, openValue, closeValue, stopLoss, noLoose, valueTp] = Algo_000test_BktOffline(matrix)

%
% DESCRIPTION:
% -----------------------------------------------------------------------
% This is the general modular structure for creating the Algos:
% 01 - coreState ..................... first filter manager
% 02a - takeProfitManager ............ manager for TP and SL closing 
% 03a - decMaker.decisionReal ........ second filter manager for virtual 
%                                      running mode
% 02b - takeProfitManager ............ manager for defining TP and SL 
% 03b - decMaker.decisionDirection ... operative manager for opening
%                                      direction
% 03c - decMaker.calcLock ............ lock settings manager
%
% INPUT parameters:
% -----------------------------------------------------------------------
% matrix ... two-dimensional vector containing the following coloumns: 
%            1-opening prices
%            2-min values
%            3-max values
%            4-closing prices
%            5-volumes         
%
% OUTPUT parameters:
% -----------------------------------------------------------------------
% to do
%
%
% EXAMPLE of use:
% -----------------------------------------------------------------------
% to do
%

global      map;
% global      log;
persistent  counter;
persistent  countCycle;


openValue = 0;
closeValue= 0;
stopLoss  = 0;
noLoose   = 0;
valueTp   = 0;
%real      = 0;



cState = coreState_real02;
decMaker = DecisionMaker_real02;


if(isempty(map))
    map = containers.Map;
    counter = 0;
end

%display(countCycle);
if(isempty(countCycle) || countCycle == 0)
    countCycle = 1;
    operationState = OperationState;
    params         = Parameters;
    map('Algo_testBktOffline') = RealAlgo(operationState,params);
    oper = 0;
    return;
end

ra = map('Algo_testBktOffline');
remove(map,'Algo_testBktOffline');

params         = ra.p;
operationState = ra.os;


%lows           = matrix(:,2);
%highs          = matrix(:,3);
chiusure        = matrix(:,4);
%volumi          = matrix(:,5);



% 01
% -------- coreState filter ------------------ %
% cState.anderson(matrix,0.6,1);
% state=cState.state;
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
                
                % 03a
                % -------- decMaker filter -------------------------- %
%                 decMaker.decisionReal4(chiusure);
%                 real=decMaker.real;



                % 02b
                % -------- takeProfitManager: define TP and SL ------ %
                %                      TO CREATE
                TakeP=1;
                StopL=1;
                
                % 03b
                % -------- decMaker direction manager --------------- %
                [params, operationState,counter] = decMaker.decisionDirection1(chiusure,params,operationState,TakeP,StopL);
                display('operazione aperta');
                
                % 03c
                % -------- decMaker lock manager -------------------- %
                operationState = decMaker.calcLock(operationState);
                                
            end
        end
    end
    
    
end

oper = operationState.actualOperation;

real_Algo = RealAlgo(operationState,params);
map('Algo_testBktOffline')     = real_Algo;

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

