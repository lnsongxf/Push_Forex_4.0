function [name]=dateNameCreator (period)

date=regexp(period,'[ - ]', 'split');
date1=regexp(date{1}(1),'/', 'split');
date2=regexp(date{1}(4),'/', 'split');

month1 = date1{1}(1);
month2 = date2{1}(1);
day1   = date1{1}(2);
day2   = date2{1}(2);
year1  = date1{1}(3);
year2  = date2{1}(3);

firstDate = num2str(cell2mat(strcat(month1,day1,year1)));
lastDate  = num2str(cell2mat(strcat(month2,day2,year2)));

localPath='C:\Users\alericci\Desktop\Forex 4.0 noShared\performance comparison\';
if isdir(localPath)
    name=strcat(localPath,firstDate,'_',lastDate,'_Perf');
else
    currentFolder = pwd;
    folderName = strcat(currentFolder,'\performance comparison\');
    mkdir(folderName);
    name=strcat(folderName,firstDate,'_',lastDate,'_Perf');
end


% [~, Month1] = month(date1);
% Day1 = num2str(day(date1));
% firstDate=strcat(Day1,Month1);
%
% Year2 = num2str(year(date2));
% [~, Month2] = month(date2);
% Day2 = num2str(day(date2));
% lastDate=strcat(Day2,Month2,'_',Year2);
%
% name=strcat(path,'P_',firstDate,'_',lastDate);

end