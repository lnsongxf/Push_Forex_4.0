classdef SingleValue < handle
    %VALUE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        date;
        time;
        open;
        close;
        high;
        low;
        vol;
    end
    
    methods
        function obj = SingleValue(array)
            l = length(array);
            switch l
                case 4
                    obj.open = array(1);
                    obj.high = array(2);
                    obj.low = array(3);
                    obj.close = array(4);
                    
                case 5
                    obj.open  = array(1);
                    obj.high  = array(2);
                    obj.low   = array(3);
                    obj.close = array(4);
                    obj.vol   = array(5);
                case 7
                    obj.date  = array(1);
                    obj.time  = array(2);
                    obj.open  = array(3);
                    obj.high  = array(4);
                    obj.low   = array(5);
                    obj.close = array(6);
                    obj.vol   = array(7);
                case 11
                    obj.date  = [array(6) array(7) array(8)];
                    obj.time  = [array(9) array(10) array(11)];
                    obj.open  = array(1);
                    obj.high  = array(2);
                    obj.low   = array(3);
                    obj.close = array(4);
                    obj.vol   = array(5);
            end
        end
    end
    
end

