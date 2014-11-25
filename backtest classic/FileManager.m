classdef FileManager < handle
    %FILEMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        path        = 'F:\algorithms_RAV\Matlab_Algos\classes/';
        extension   = '.csv';
        fileName;
    end
    properties (Dependent = true, SetAccess = private)
        completePath;
    end
    
    methods
        function value = get.completePath(obj)
            value = obj.buildPath;
        end
        function set.completePath(obj,~)
            obj.buildPath;
        end
        function value = buildPath(obj)
           value = strcat(obj.path,obj.fileName,obj.extension); 
        end
        function obj = FileManager(inFilename, timeInterval)
           obj.fileName = strcat(inFilename,num2str(timeInterval)); 
        end
    end
    
end

