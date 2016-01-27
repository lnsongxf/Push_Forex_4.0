function [TakeProfitPrice,StopLossPrice,newTakeP,newStopL,dynamicOn] = closingDiffexpert(OpenPrice,LastClosePrice,direction,TakeP,StopL, ~, dynamicParameters)

% ------------ do not modify inside -----------------
TakeProfitPrice = OpenPrice + direction * TakeP;
StopLossPrice   = OpenPrice - direction * StopL;
newTakeP = TakeP;
newStopL = StopL;
dynamicOn = 0;
% ---------------------------------------------------


% ------------------IDEA BEHIND----------------------
% If the current price allows a possible gain, reset the SL and TP price to
% some values ...
% ---------------------------------------------------


%
minTP          = dynamicParameters {1};
diffexpert     = dynamicParameters {2};
difflimit      = dynamicParameters {3};
ShrinkFactorSL = dynamicParameters {4};
ShrinkSL       = dynamicParameters {5};

distance       = direction * ( LastClosePrice - OpenPrice );
diffvalue      = (direction * diffexpert);
MeanPrice      = floor( (TakeProfitPrice + StopLossPrice) / 2 );
distanceNewSL  =  (( direction * ( LastClosePrice - MeanPrice ) ) * ShrinkFactorSL) + ShrinkSL;

display(strcat('diffvalue =',num2str(diffvalue)));

if ( distance > minTP ) && (diffvalue > difflimit)
    
    TakeProfitPrice = TakeProfitPrice + direction * minTP;
    StopLossPrice = StopLossPrice + direction * ( distanceNewSL );
    
    newTakeP = (TakeProfitPrice - OpenPrice) * direction;
    newStopL = (OpenPrice - StopLossPrice) * direction;
    
    display(strcat('dynamical TP = ',num2str(newTakeP),' SL = ',num2str(newStopL)));
    
    dynamicOn = 1;
    
end

end