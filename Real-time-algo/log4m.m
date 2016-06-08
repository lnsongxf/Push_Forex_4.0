classdef log4m < handle
    %LOG4M This is a simple logger based on the idea of the popular log4j.
    %
    % Description: Log4m is designed to be relatively fast and very easy to
    % use. It has been designed to work well in a matlab environment.
    % Please contact me (info below) with any questions or suggestions!
    %
    %
    % Author:
    %       Luke Winslow <lawinslow@gmail.com>
    % Heavily modified version of 'log4matlab' which can be found here:
    %       http://www.mathworks.com/matlabcentral/fileexchange/33532-log4matlab
    %
    %  Description: Log4m is designed to be relatively fast and very easy to use. It has been designed to work well in a matlab environment.
    %  log4m uses the same level system as log4j {'ALL','TRACE','DEBUG','INFO','WARN','ERROR','FATAL','OFF'} and is an attempt to create a single-file, 
    %  robust drop-in system for more advanced logging. It only provides a single logger object within an entire matlab instance, so you don't need to track a file or object reference.
    %  I currently use this in long-running compiled jobs so I can track how they are performing without manual intervention or observation.
    % 
    % ----------------------------------------
    % 
    % Example: 
    % %To create the logger reference: 
    % L = log4m.getLogger('logfile.txt');
    % 
    % % To log an error event 
    % L.error('exampleFunction','An error occurred');
    % 
    % % To log a trace event 
    % L.trace('function','Trace this event');
    % 
    % --
    % 
    % If you want to display all logging information to the command prompt while only writing major events worse than an error to the log file,
    % you can set the desired log levels accordingly.
    % 
    % L.setCommandWindowLevel(L.ALL); 
    % L.setLogLevel(L.ERROR);
    % 
    % Now all messages will be displayed to the command prompt while only error and fatal messages will be logged to file.
    % 
    % ----------------------------------------- 
    % Note: This project is similar to the log4matlab code acknowledged, but is easier to use and has an API more in the 'matlab style'.
    %
    
    
    properties (Constant)
        ALL = 0;
        TRACE = 1;
        DEBUG = 2;
        INFO = 3;
        WARN = 4;
        ERROR = 5;
        FATAL = 6;
        OFF = 7;
    end
    
    properties(Access = protected)
        logger;
        lFile;
    end
    
    properties(SetAccess = protected)
        fullpath = 'log4m.log';  %Default file
        commandWindowLevel = log4m.ALL;
        logLevel = log4m.INFO;
    end
    
    methods (Static)
        function obj = getLogger( logPath )
            %GETLOGGER Returns instance unique logger object.
            %   PARAMS:
            %       logPath - Relative or absolute path to desired logfile.
            %   OUTPUT:
            %       obj - Reference to signular logger object.
            %
            
            if(nargin == 0)
                logPath = 'log4m.log';
            elseif(nargin > 1)
                error('getLogger only accepts one parameter input');
            end
            
%             persistent localObj;
%             if isempty(localObj) || ~isvalid(localObj)
%                 localObj = log4m(logPath);
%             end
%             obj = localObj;
            
            obj = log4m(logPath);
        end
        
        function testSpeed( logPath )
            %TESTSPEED Gives a brief idea of the time required to log.
            %
            %   Description: One major concern with logging is the
            %   performance hit an application takes when heavy logging is
            %   introduced. This function does a quick speed test to give
            %   the user an idea of how various types of logging will
            %   perform on their system.
            %
            
            L = log4m.getLogger(logPath);
            
            
            disp('1e5 logs when logging only to command window');
            
            L.setCommandWindowLevel(L.TRACE);
            L.setLogLevel(L.OFF);
            tic;
            for i=1:1e5
                L.trace('log4mTest','test');
            end
            
            disp('1e5 logs when logging only to command window');
            toc;
            
            disp('1e6 logs when logging is off');
            
            L.setCommandWindowLevel(L.OFF);
            L.setLogLevel(L.OFF);
            tic;
            for i=1:1e6
                L.trace('log4mTest','test');
            end
            toc;
            
            disp('1e4 logs when logging to file');
            
            L.setCommandWindowLevel(L.OFF);
            L.setLogLevel(L.TRACE);
            tic;
            for i=1:1e4
                L.trace('log4mTest','test');
            end
            toc;
            
        end
    end
    
    
    %% Public Methods Section %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function setFilename(self,logPath)
            %SETFILENAME Change the location of the text log file.
            %
            %   PARAMETERS:
            %       logPath - Name or full path of desired logfile
            %
            
            [fid,message] = fopen(logPath, 'a');
            
            if(fid < 0)
                error(['Problem with supplied logfile path: ' message]);
            end
            fclose(fid);
            
            self.fullpath = logPath;
        end
        
        
        function setCommandWindowLevel(self,loggerIdentifier)
            self.commandWindowLevel = loggerIdentifier;
        end
        
        
        function setLogLevel(self,logLevel)
            self.logLevel = logLevel;
        end
        
        
        %% The public Logging methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function trace(self, funcName, message)
            %TRACE Log a message with the TRACE level
            %
            %   PARAMETERS:
            %       funcName - Name of the function or location from which
            %       message is coming.
            %       message - Text of message to log.
            %
            self.writeLog(self.TRACE,funcName,message);
        end
        
        function debug(self, funcName, message)
            %TRACE Log a message with the DEBUG level
            %
            %   PARAMETERS:
            %       funcName - Name of the function or location from which
            %       message is coming.
            %       message - Text of message to log.
            %
            self.writeLog(self.DEBUG,funcName,message);
        end
        
        
        function info(self, funcName, message)
            %TRACE Log a message with the INFO level
            %
            %   PARAMETERS:
            %       funcName - Name of the function or location from which
            %       message is coming.
            %       message - Text of message to log.
            %
            self.writeLog(self.INFO,funcName,message);
        end
        
        
        function warn(self, funcName, message)
            %TRACE Log a message with the WARN level
            %
            %   PARAMETERS:
            %       funcName - Name of the function or location from which
            %       message is coming.
            %       message - Text of message to log.
            %
            self.writeLog(self.WARN,funcName,message);
        end
        
        
        function error(self, funcName, message)
            %TRACE Log a message with the ERROR level
            %
            %   PARAMETERS:
            %       funcName - Name of the function or location from which
            %       message is coming.
            %       message - Text of message to log.
            %
            self.writeLog(self.ERROR,funcName,message);
        end
        
        
        function fatal(self, funcName, message)
            %TRACE Log a message with the FATAL level
            %
            %   PARAMETERS:
            %       funcName - Name of the function or location from which
            %       message is coming.
            %       message - Text of message to log.
            %
            self.writeLog(self.FATAL,funcName,message);
        end
        
    end
    
    %% Private Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Unless you're modifying this, these should be of little concern to you.
    methods (Access = private)
        
        function self = log4m(fullpath_passed)
            
            if(nargin > 0)
                path = fullpath_passed;
            end
            self.setFilename(path);
        end
        
        %% WriteToFile
        function writeLog(self,level,scriptName,message)
            
            % If necessary write to command window
            if( self.commandWindowLevel <= level )
                fprintf('%s:%s\n', scriptName, message);
            end
            
            %If currently set log level is too high, just skip this log
            if(self.logLevel > level)
                return;
            end
            
            % set up our level string
            switch level
                case{self.TRACE}
                    levelStr = 'TRACE';
                case{self.DEBUG}
                    levelStr = 'DEBUG';
                case{self.INFO}
                    levelStr = 'INFO';
                case{self.WARN}
                    levelStr = 'WARN';
                case{self.ERROR}
                    levelStr = 'ERROR';
                case{self.FATAL}
                    levelStr = 'FATAL';
                otherwise
                    levelStr = 'UNKNOWN';
            end
            
            % Append new log to log file
            try
                fid = fopen(self.fullpath,'a');
                fprintf(fid,'%s %s %s - %s\r\n' ...
                    , datestr(now,'yyyy-mm-dd HH:MM:SS,FFF') ...
                    , levelStr ...
                    , scriptName ... % Have left this one with the '.' if it is passed
                    , message);
                fclose(fid);
            catch ME_1
                display(ME_1);
            end
        end
    end
    
end

