function [LogObj,logFile] = createLogFile (logFolderName,nameAlgo,nFile)
    logFileName=strcat('logfile',nameAlgo,'_',num2str(nFile),'.txt');
    logFile=strcat(logFolderName,logFileName);
    LogObj = log4m.getLogger(logFile);
    LogObj.setCommandWindowLevel(LogObj.ALL);
    LogObj.setLogLevel(LogObj.ALL);
    LogObj.fatal('new log file',num2str(cell2mat(strcat('-------',{' '},num2str(nFile),{' '},'--------'))) );
end