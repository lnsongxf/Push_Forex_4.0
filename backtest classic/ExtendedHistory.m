classdef ExtendedHistory < History
    
    
    properties
        extTimeInterval; %unita di misura: minuti
    end
    properties(SetAccess = protected)
        actMatrixVal;
    end
    methods
        function val = getExactValue(obj,fIndex,counter)
           counter = mod(counter,obj.extTimeInterval);
           div = obj.extTimeInterval/obj.timeInterval;
           val = obj.actMatrixVal(fIndex*div+counter,:);
        end
        function obj = ExtendedHistory(inSymbol, time)
            obj = obj@History(inSymbol);
            obj.extTimeInterval     = time;
        end
        function obj = loadHistory(obj)
            delete(obj.fileHist);
            obj.fileHist    = FileManager(obj.symbol,obj.timeInterval);
            path            = obj.fileHist.completePath;
            array           = csvread(path);
            obj.actMatrixVal= array;
            obj.matrixVal   = obj.actMatrixVal;
            
            vp = obj.matrixVal;
            l = length(vp);
            rs= mod(l,obj.extTimeInterval);
            div = obj.extTimeInterval/obj.timeInterval;
            vp = vp(rs+1:end,:);
            v = vp(1:div:length(vp),:);

            for i = 1 : length(v)-2
                temp = max(vp((i-1)*div+1:i*div,2));
                v(i,2) = temp;
                temp = min(vp((i-1)*div+1:i*div,3));
                v(i,3) = temp;
                v(i,5) = sum(vp((i-1)*div+1:i*div,5));
            end
            obj.matrixVal = v;
            
            clear array;
            clear path;
        end
       
    end
    
end

