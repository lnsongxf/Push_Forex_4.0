function [name]=dateNameCreator (period)

path='C:\Users\Ale\algorithms_RAV\QUANT\_TEST Algos\Demo-BktWeb\';

date=regexp(period,'[ - ]', 'split');
date1=date{1}(1);
date2=date{1}(4);

[~, Month1] = month(date1);
Day1 = num2str(day(date1));
firstDate=strcat(Day1,Month1);

Year2 = num2str(year(date2));
[~, Month2] = month(date2);
Day2 = num2str(day(date2));
lastDate=strcat(Day2,Month2,'_',Year2);

name=strcat(path,'P_',firstDate,'_',lastDate);

end