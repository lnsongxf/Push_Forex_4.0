function [oper, openValue, closeValue, stopLoss, takeProfit, minReturn] = Algo_004_statTrend(matrix,newTimeScalePoint,newTimeScalePointEnd,openValueReal,timeSeriesProperties,indexHisData)

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
% matrix: two-dimensional vector containing the following coloumns:
%            1-opening prices
%            2-min values
%            3-max values
%            4-closing prices
%            5-volumes
%         the last row of the matrix contains the last price, which is only used to check
%         wheter to close an open operation
%
% newTimeScalePoint: if = 1 and no operations are open, the algo will compute the indicator,
%         otherwhise it will only check if closing conditions are satisfied
%
% openValueReal: opening price if an operation is open
%
% OUTPUT parameters:
% -----------------------------------------------------------------------
% oper: sign of operation
% openValue: suggested opening price
% closeValue: suggested closing price
% stopLoss: suggested SL
% noLoose: suggested TP                          <-  THIS IS CONFUSING
% valueTp: NOT USED IN THE MAIN PROGRAM !!!!     <-  THIS IS CONFUSING
% st: output from the stationarity test
%
% EXAMPLE of use:
% -----------------------------------------------------------------------
% to be used in bktOffline or in demo/live mode
%

global     map;
persistent counter;
persistent countCycle;

openValue  = 0;
closeValue = 0;
stopLoss   = 0;
takeProfit = 0;
minReturn  = 0;
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
    map('Algo_004_statTrend') = RealAlgo(operationState,params);
    oper      = 0;
    return;
end


ra = map('Algo_004_statTrend');
remove(map,'Algo_004_statTrend');

params = ra.p;
operationState = ra.os;


%highs           = matrix(:,2);
%lows         = matrix(:,3);
chiusure        = matrix(:,4);
%volumi          = matrix(:,5);

if newTimeScalePointEnd
    params.set('endOfcandelStick',1);
else
    params.set('endOfcandelStick',0);
end


% controlla se ho dei nuovi dati sulla newTimeScale
if newTimeScalePoint
    
    % 01a
    % -------- stationarity Test ------------------- %
    
    st.stationarityTests(chiusure(1:end-1),30,0);
    
    a=st.HurstExponent;
    c=st.pValue;
    d=st.halflife;
    
    % 01b
    % -------- .................. ------------------ %
    if isfinite(timeSeriesProperties.HurstExponent(end))
        smoothCoeff = 0.5;
        [timeSeriesProperties.HurstSmooth,timeSeriesProperties.HurstDiff]=smoothDiff(timeSeriesProperties.HurstExponent,smoothCoeff);
    end
    
    
    % ----- update timeSeriesProperties ------------ %
    b=mean(timeSeriesProperties.HurstDiff(end-5:end-1));
    e=timeSeriesProperties.HurstSmooth(end);
    
    timeSeriesProperties.addPoint(a,b,c,d,e);
    
%     plot(timeSeriesProperties.HurstExponent,'-b');
%     hold on
%     plot(timeSeriesProperties.HurstSmooth,'-or');
%     
%     cla

    % 01c
    % -------- coreState filter -------------------- %
    cState.core_Algo_004_statTrend(chiusure(1:end-1),params,17,51,timeSeriesProperties);
    
end
state=cState.state;


if operationState.lock
    
    counter = counter + 1;
    
    if(counter > operationState.lockDuration )
        
        counter = 0;
        operationState.lock = 0;
        
    end
    
else
    
    if abs(operationState.actualOperation) > 0 && newTimeScalePoint == 0 ;
        
        % 02a
        % -------- takeProfitManager: close for TP or SL ------ %
        if openValueReal > 0

            params.set('openValue_',openValueReal);
            params.set('closeTime_',indexHisData);
            
            openingPrice = openValueReal;
            actualPrice  = chiusure(end);
            actualReturn = (actualPrice - openingPrice)*operationState.actualOperation;
            operationState.minimumReturn = min(operationState.minimumReturn,actualReturn);
            minReturn = operationState.minimumReturn;
   
            openingTime = params.get('openTime__');
            closingTime = params.get('closeTime_');
            operationState.latency = closingTime - openingTime;
            
            dynamicParameters {1} = 0;
            dynamicParameters {2} = 1;
            [params,TakeProfitPrice,StopLossPrice,dynamicOn] = dynamicalTPandSLManager(operationState, chiusure, params, @closingShrinkingBands, dynamicParameters);
            if dynamicOn  == 1
                params.set('openTime__',indexHisData);
            end
            
            latencyTreshold = 1000000;    % latency treshold in minutes
            [operationState,~, params] = directTakeProfitManager (operationState, chiusure, params,TakeProfitPrice,StopLossPrice, latencyTreshold);
            
        elseif openValueReal < 0
            
            operationState = params.resetStatusOnFailureOpening (operationState);
            display('reset Algo status');
            
        end
        
    elseif abs(operationState.actualOperation) == 0
        
        if state
            
            % 02b
            % -------- takeProfitManager: define TP and SL ------ %
            TakeP = floor(cState.suggestedTP);
            StopL = floor(cState.suggestedSL);
            display(['SL = ' num2str(StopL),' TP = ' num2str(TakeP)]) ;
            
            % 03b
            % -------- decMaker direction manager --------------- %
            [params, operationState, counter] = decMaker.decisionDirectionByCore(chiusure,params,operationState,cState,TakeP,StopL);
            
            params.set('openTime__',indexHisData);            
            display('Matlab ha deciso di aprire');
                       
            % 03c
            % -------- decMaker lock manager -------------------- %
            operationState = decMaker.calcLock(operationState);
            
        end
        
    end
    
end

oper      = operationState.actualOperation;

real_Algo = RealAlgo(operationState,params);
map('Algo_004_statTrend')     = real_Algo;

openValue   = params.get('openValue_');
closeValue  = params.get('closeValue');
stopLoss    = params.get('stopLoss__');
takeProfit  = params.get('noLoose___');

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

