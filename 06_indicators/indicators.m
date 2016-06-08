classdef indicators < handle
    
    %
    % DESCRIPTION:
    % -------------------------------------------------------------
    % This class collect many functions for the calculation of
    % specific trading indicators useful for bulding up the coreState of
    % the Algos. Ideed all the indicators useful for bulding up an entry/exit
    % strategy have to be included as method of this class.
    %
    
    properties
    
     HurstExponent = nan(100,1);
     HurstDiff     = nan(100,1);
     pValue        = nan(100,1);
     halflife      = nan(100,1);
     HurstSmooth   = nan(100,1);
        
    end
    
    methods
        
        function addPoint(obj,HurstPoint,HurstDiffPoint, pValuePoint, halflifePoint, HurstSmoothPoint)
           
            obj.HurstExponent = [ obj.HurstExponent(2:end) ; HurstPoint ];
            obj.HurstDiff     = [ obj.HurstDiff(2:end) ; HurstDiffPoint ];            
            obj.pValue        = [ obj.pValue(2:end) ; pValuePoint ];
            obj.halflife      = [ obj.halflife(2:end) ; halflifePoint ];
            obj.HurstSmooth   = [ obj.HurstSmooth(2:end) ; HurstSmoothPoint ];
            
        end
    
    end

    
end
