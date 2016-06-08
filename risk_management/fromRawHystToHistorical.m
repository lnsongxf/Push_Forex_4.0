function [HistData_1min_,HistData_freq_]=fromRawHystToHistorical(actTimeScale,newTimeScale)

%%% NOTE
% actTimeScale = 1
% newTimeScale or freq ... frequency (ex: 5 min)
% [history_1min]=fromRawHystToHistorical
% [outputHyst,HistData_freq_]=fromRawHystToHistorical(actTimeScale,newTimeScale)
% 
% 

tic
filename = 'EURUSD1_09032016_13042016';
%filename = '2013_jan_sept_5min_history';   use an input historical with specific freq 
%                                           if the backtest is done on it and not on rescaled data
filedir = 'C:\Users\alericci\Desktop\Forex 4.0 noShared\';
Fullname  = strcat(filedir, filename,'.mat');

tempMatrix = load(Fullname);
matrixHist=tempMatrix.history;

expert=TimeSeriesExpert_11;

date=strcat(num2str(matrixHist(:,7)+1),'/',num2str(matrixHist(:,8)),'/',num2str(matrixHist(:,6)),{' '},num2str(matrixHist(:,9)),':',num2str(matrixHist(:,10)));
dateNum=datenum(date, 'mm/dd/yyyy HH:MM');


HistData_1min_(:,1)=matrixHist(:,1);        % opening price
HistData_1min_(:,2)=matrixHist(:,2);        % min price
HistData_1min_(:,3)=matrixHist(:,3);        % max price
HistData_1min_(:,4)=matrixHist(:,4);        % closure
HistData_1min_(:,5)=matrixHist(:,5);        % volume
HistData_1min_(:,6)=dateNum;                % opening date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')

expert=expert.readData(matrixHist);
expert=expert.rescaleData(HistData_1min_,actTimeScale,newTimeScale);
HistData_freq_(:,1)=expert.openVrescaled;
HistData_freq_(:,2)=expert.maxVrescaled;           % da correggere anche nella classe TimeSeriesExpert (sono in min)
HistData_freq_(:,3)=expert.minVrescaled;           % da correggere anche nella classe TimeSeriesExpert (sono in max)
HistData_freq_(:,4)=expert.closeVrescaled;
HistData_freq_(:,5)=expert.volrescaled;
HistData_freq_(:,6)=expert.openDrescaled;

toc

end
