classdef History < handle
    
    
    properties
        symbol          = 'EURUSD';
        fileHist;
        timeInterval; %unita di misura: minuti
    end
    properties(SetAccess = protected)
        matrixVal;
    end
    methods
        function set.matrixVal(obj,matrix)
            obj.matrixVal = matrix;
        end
        function val = getSingleValue(obj,index)
            array = obj.matrixVal(index,:);
            val = SingleValue(array);
        end
        function val = getLength(obj)
            val = length(obj.matrixVal);
        end
        function obj = History(inSymbol)
            obj.symbol          = inSymbol;
            obj.timeInterval    = 1;
        end
        function obj = loadHistory(obj)
            delete(obj.fileHist);
            obj.fileHist    = FileManager(obj.symbol,obj.timeInterval);
            path            = obj.fileHist.completePath;
            array           = csvread(path);
            obj.matrixVal   = array;
            clear array;
            clear path;
        end
        %{
        function vector = buildVector()
            
        end
        %}
    end
    
end

