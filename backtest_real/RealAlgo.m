classdef RealAlgo < handle
    %VALUE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        os;
        p;
    end
    
    methods
        function obj = RealAlgo(os,p)
            obj.os = os;
            obj.p  = p;
        end
    end
end