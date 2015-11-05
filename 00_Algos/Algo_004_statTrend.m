function [oper, openValue, closeValue, stopLoss, noLoose, valueTp,st] = Algo_004_statTrend(matrix,newTimeScalePoint)

%
% DESCRIPTION:
% -----------------------------------------------------------------------
% This is the general modular structure for creating the Algos:
% 01a - coreState .................... first filter manager
% 01b - stationarity ................. stationarity Test
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
st = stationarity;


if(isempty(map))
    
    map = containers.Map;
    counter = 0;
end


%display(countCycle);
if(isempty(countCycle) || countCycle == 0)

    countCycle = 1;
    operationState = OperationState;
    params = Parameters;
    map('Algo_002_Ale') = RealAlgo(operationState,params);
    oper = 0;
    return;
end


ra = map('Algo_002_Ale');
remove(map,'Algo_002_Ale');

params = ra.p;
operationState = ra.os;


%lows           = matrix(:,2);
%highs          = matrix(:,3);
chiusure        = matrix(:,4);
%volumi          = matrix(:,5);

if newTimeScalePoint==1 % controlla se ho dei nuovi dati sulla newTimeScale
    % 01a
    % -------- coreState filter ------------------ %
    cState.core_Algo_004_statTrend(chiusure(1:end-1),params);
    
    
    % 01b
    % -------- stationarity Test ------------------ %
    st.stationarityTests(chiusure(1:end-1),30,0);
end
stateC = cState.state;
if st.HurstExponent>0.5
    stateH=1;
else
    stateH=0;
end
state=stateC*stateH;


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
        %[operationState,~,params] = takeProfitManager(operationState,chiusure,params);
        [operationState,~, params] = timeClosureManager (operationState, chiusure, params,5000);
        
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
                TakeP = floor(cState.suggestedTP);
                StopL = floor(cState.suggestedSL);
                display(['SL = ' num2str(StopL),' TP = ' num2str(TakeP)]) ;
                
                % 03b
                % -------- decMaker direction manager --------------- %
                [params, operationState, counter] = decMaker.decisionDirectionByCore(chiusure,params,operationState,cState,TakeP,StopL);

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
map('Algo_002_Ale')     = real_Algo;

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
clear dev;

clear matrix;
clear ra;


end

