function [LogObj,logFile] = createLogFile (nameAlgo,nFile)
logFolderName='C:\Users\alericci\Desktop\Forex 4.0 noShared\test Logs\';
    %logFileName=strcat('logfile',nameAlgo,num2str(nFile,'_%010i'),'.txt');
    logFileName=strcat('logfile',nameAlgo,'_',num2str(nFile),'.txt');
    logFile=strcat(logFolderName,logFileName);
    LogObj = log4m.getLogger(logFile);
    LogObj.setCommandWindowLevel(LogObj.ALL);
    LogObj.setLogLevel(LogObj.ALL);
    LogObj.fatal('new log file',num2str(cell2mat(strcat('-------',{' '},num2str(nFile),{' '},'--------'))) );
end