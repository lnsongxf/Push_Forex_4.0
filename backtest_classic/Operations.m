classdef Operations < handle
    %OPERATIONS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        array = {};
        totalEarning = 0;
    end
    
    methods
        function obj = totalEarningCalculation(obj)
           obj.totalEarning = 0;
           for i = 1 : length(obj.array)
                o = obj.array{i};
                if(o.valueClose <= 0)
                    continue;
                else
                    obj.totalEarning = obj.totalEarning + o.earnCalculation;
                end
           end
        end
        function obj = addOperation(obj,arg1)
           l = length(obj.array);
           obj.array{l+1} = arg1;
        end
        function plotEarnings(obj)
            cumSum = [];
            for i = 1 : length(obj.array)
                o = obj.array{i};
                if(o.valueClose <= 0)
                    continue;
                else
                    obj.totalEarning = obj.totalEarning + o.earnCalculation;
                end
                cumSum(i) = obj.totalEarning;
            end
           plot(cumSum);
        end
        function cumSum = cumSumRet(obj)
            obj.totalEarning = 0;
            cumSum = [];
            for i = 1 : length(obj.array)
                o = obj.array{i};
                if(o.valueClose <= 0)
                    continue;
                else
                    obj.totalEarning = obj.totalEarning + o.earnCalculation;
                end
                cumSum(i) = obj.totalEarning;
            end
        end
    end
    
end

