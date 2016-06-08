function dateLastNum=dateLastCalculator (dateEnd)

% input the dateLastOperationNum as 'date' (in days please)
% A serial date number represents the whole and fractional number of days from a fixed, preset date (January 0, 0000).

dateLastOperationNum=dateEnd;
dateLastOperation=datestr(dateLastOperationNum, 'mm/dd/yyyy HH:MM');
dateLastOperationSplitted=regexp(dateLastOperation, '[ ]', 'split');
dayLastOperation=dateLastOperationSplitted(1);
timeLast='23:59';
dateLast=strcat(dayLastOperation,{' '},timeLast);
dateLastNum=datenum(dateLast, 'mm/dd/yyyy HH:MM');
%day0=dateFirstOperationNum+(dateFirstOperationNum-dateZeroNum);

end