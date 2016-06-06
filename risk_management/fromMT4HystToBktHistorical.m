function [HistData_1min,HistData_freq]=fromMT4HystToBktHistorical(actTimeScale,newTimeScale)

%
% DESCRIPTION:
% -------------------------------------------------------------
% this function reformat the hystorical data from MT4 to a standard format
% used in the bkt.
%
% INPUT parameters:
% -------------------------------------------------------------
% actTimeScale ... 1 minute time scale
% newTimeScale ... working time scale (ex: 30 mins)
%
% EXAMPLE of use:
% -------------------------------------------------------------
% [HistData_1min,HistData_freq]=fromMT4HystToBktHistorical(1,30)
%


tic

filename = '05112016_06022016_AUDCAD_1m_MT4';
filedir = 'C:\Users\alericci\Desktop\Forex 4.0 noShared\performance comparison\';
Fullname  = strcat(filedir, filename,'.csv');
factor = 10000;

format long
fileID = fopen(Fullname);
hystorical = textscan(fileID,'%s %s %f %f %f %f %f','Delimiter',',');

expert=TimeSeriesExpert_11;
date1 = num2str(cell2mat(hystorical{1,1}(:)));
date2 = num2str(cell2mat(hystorical{1,2}(:)));

date=strcat(date1,{' '},date2);
dateNum=datenum(date, 'yyyy.mm.dd HH:MM');
l=length(dateNum);

HistData_1min(:,1) = floor(hystorical{1,3}(:).*factor);        % opening price
HistData_1min(:,2) = floor(hystorical{1,4}(:).*factor);        % max price
HistData_1min(:,3) = floor(hystorical{1,5}(:).*factor);        % min price
HistData_1min(:,4) = floor(hystorical{1,6}(:).*factor);        % closure
HistData_1min(:,5) = hystorical{1,7}(:);                       % volume
HistData_1min(:,6) = dateNum;                                  % opening date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')

expert=expert.readData(HistData_1min);
expert=expert.rescaleData(HistData_1min,actTimeScale,newTimeScale);
HistData_freq(:,1)=expert.openVrescaled;
HistData_freq(:,2)=expert.maxVrescaled;
HistData_freq(:,3)=expert.minVrescaled;
HistData_freq(:,4)=expert.closeVrescaled;
HistData_freq(:,5)=expert.volrescaled;
HistData_freq(:,6)=expert.openDrescaled;

suffix = '_bkt';
savingName = strcat(filedir,filename,suffix,'.csv');
% dlmwrite(savingName, HistData_1min, '-append','precision','%.3f%.1f%.1f%.1f%f%.10f') ;

fileID = fopen(savingName,'w');
formatSpec = '%.1f,%.1f,%.1f,%.1f,%.0f,%.10f\r\n';
for i = 1:l
    fprintf(fileID,formatSpec,HistData_1min(i,:));
end
fclose(fileID);


toc

end




