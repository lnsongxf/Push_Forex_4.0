classdef MapIterator < handle
    
    
    properties
        map
    end
    properties (Access = private)
        sizeOfMap
        index
        mk
    end
    
    methods
        function obj = MapIterator(inMap)
            obj.map     = containers.Map;
            obj.map     = inMap;
            obj.index   = 0;
            obj.mk      = char(keys(obj.map));
            
            s           = size(obj.mk);
            obj.sizeOfMap = s(1);
        end
        function key = next(obj)
            obj.index = obj.index+1;
            key = obj.mk(obj.index,:);
        end
        function bool = hasNext(obj)
            bool = obj.index < obj.sizeOfMap;
        end
        function obj = reset(obj)
            obj.index = 0;
        end
    end
    
end

