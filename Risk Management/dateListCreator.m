function [date]=dateListCreator(dateStart,dateEnd,timeStep)

% timeStep in minutes
% 1 day == 1440

% NOTE:
% date(:,1) ... date in days
% date(:,2) ... day of the week
% date(:,3) ... name of day of the week

dateZeroNum=dateZeroCalculator (dateStart);
dateLastNum=dateLastCalculator (dateEnd);

step=timeStep/(24*60);
dateListNum=(dateZeroNum:step:dateLastNum)';


l=length(dateListNum);
DayNumber=zeros(l,1);

for i = 1: l;
    dateList=datestr(dateListNum(i),'dd/mm/yyyy HH:MM');
    dateListSplitted=regexp(dateList, '[ ]', 'split');
    dayList=dateListSplitted(1);
    [n] = weekday(dayList,'dd/mm/yyyy');
    DayNumber(i,1)=n;
end

date(:,1)=dateListNum;
date(:,2)=DayNumber;

end