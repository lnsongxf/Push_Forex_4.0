function [outputHyst]=fromRawHystToHistorical

%%% NOTE
% 
% 
% 

filename = '2013_jan_oct_1min_history';
filedir = 'C:\Users\Ale\algorithms_RAV\QUANT\_TEST Algos\Demo-BktWeb\';
Fullname  = strcat(filedir, filename,'.mat');

tempMatrix = load(Fullname);
matrixHist=tempMatrix.history;


date=strcat(num2str(matrixHist(:,7)+1),'/',num2str(matrixHist(:,8)),'/',num2str(matrixHist(:,6)),{' '},num2str(matrixHist(:,9)),':',num2str(matrixHist(:,10)));
dateNum=datenum(date, 'mm/dd/yyyy HH:MM');


outputHyst(:,1)=matrixHist(:,1);        % opening price
outputHyst(:,2)=matrixHist(:,2);        % min price
outputHyst(:,3)=matrixHist(:,3);        % max price
outputHyst(:,4)=matrixHist(:,4);        % closure
outputHyst(:,5)=matrixHist(:,5);        % volume
outputHyst(:,6)=dateNum;                % opening date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')

end
