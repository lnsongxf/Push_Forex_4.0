classdef TimeManager
    
    
    properties(Constant)
        hour = 60;
        day  = 60*24;
        week = 60*24*5;
    end
    
    methods (Static)
        function value = shiftWeeks(index,shift)
            value = index + shift*TimeManager.week;
        end
        function value = shiftDays(index,shift)
            value = index + shift*TimeManager.day;
        end
    end
    
end

