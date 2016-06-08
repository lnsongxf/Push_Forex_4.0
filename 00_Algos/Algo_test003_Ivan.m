function [oper, openValue, closeValue, stopLoss, noLoose, valueTp, real] = Algo_009test_Ivan(matrix, BigPointValue, intialRiskLimit)

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
persistent  counter;
persistent  countCycle;


openValue = 0;
closeValue= 0;
stopLoss  = 0;
noLoose   = 0;
valueTp   = 0;





if(isempty(map))
    map = containers.Map;
    counter = 0;
end

if(isempty(countCycle) || countCycle == 0)
    countCycle = 1;
    operationState = OperationState;
    params         = Parameters;
    map('Pegasus') = RealAlgo(operationState,params);
    oper = 0;
    real = 0;
    return;
end

ra = map('Pegasus');
remove(map,'Pegasus');

params         = ra.p;
operationState = ra.os;


chiusure        = matrix(:,4);



% 01
% -------- coreState filter ------------------ %
%state=cState.state;
state=1;           % in case of no coreState filter


%initialize variables
close = matrix(:,4);
value1 = avg(close(end-99:end));
value2 = (close(end) - value1)*BigPointValue;
value3 = (value1 - close(end))*BigPointValue;

std100 = std(close(end-99:end));
upperBand = value1 + std100;
lowerBand = value1 - std100;
Large_ATR = 2*(AvgTrueRange(matrix,10))

cState = coreState_Pegasus;
decMaker = DecisionMaker_Pegasus;

if(cState.MarketPosition == 0)
    if ( decMaker.longOpen(matrix,upperBand,value2,intialRiskLimit) )
        % long open
        cState.MarketPosition = 1;
    elseif ( shortOpen(matrix,lowerBand,value3,intialRiskLimit) )
        % short open
        cState.MarketPosition = -1;
    end
end

if(cState.MarketPosition == 1)
    if ( longExit(matrix,value1,trueRange,Large_ATR) )
        % long exit
        cState.MarketPosition = 0;
    end
end

if(cState.MarketPosition == -1)
    if ( shortExit(matrix,value1,trueRange,Large_ATR) )
        % short exit
        cState.MarketPosition = 0;
    end
end

oper = operationState.actualOperation;
real_Algo = RealAlgo(operationState,params);
map('Pegasus')     = real_Algo;


openValue = params.get('openValue_');
closeValue= params.get('closeValue');
stopLoss  = params.get('stopLoss__');
noLoose   = params.get('noLoose___');
valueTp   = params.get('valueTp___');
real      = params.get('real______');


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

%display(oper);



oper = oper * real;
display(real);
display(oper);

end

