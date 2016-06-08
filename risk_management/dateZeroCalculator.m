function dateZeroNum=dateZeroCalculator (dateStart)

% input the dateFirstOperationNum as 'date' (in days please)
% A serial date number represents the whole and fractional number of days from a fixed, preset date (January 0, 0000).

dateFirstOperationNum=dateStart;
dateFirstOperation=datestr(dateFirstOperationNum, 'mm/dd/yyyy HH:MM');
dateFirstOperationSplitted=regexp(dateFirstOperation, '[ ]', 'split');
dayFirstOperation=dateFirstOperationSplitted(1);
timeZero='00:00';
dateZero=strcat(dayFirstOperation(1),{' '},timeZero);
dateZeroNum=datenum(dateZero, 'mm/dd/yyyy HH:MM');
%day0=dateFirstOperationNum+(dateFirstOperationNum-dateZeroNum);

end