
function [outputFxbookDemo]=fromFxbookToMatrix

%%% ATTENTION:
% the input Demo .csv is an up-down flipped matrix respect to our standard,
% fist row is last operation.
% before to start the conversion, all the coloumns of Demo .csv matrix have been flipped up-down

filename = '2013_14Oct_15Nov_FxBook';
filedir = 'C:\Users\Ale\algorithms_RAV\QUANT\_TEST Algos\Demo-BktWeb\';
Fullname  = strcat(filedir, filename,'.csv');

fid1 = fopen(Fullname, 'r');
D = textscan(fid1,'%s%s%s%s%f%f%f%f%f%f%f%f%f%s%f%s%f%s%f%f%f%f%f%f%f%f%f%f', 'Delimiter', ',', 'HeaderLines', 1);
fclose(fid1);

d1=datenum(D{1}, 'mm/dd/yyyy HH:MM');
d2=datenum(D{2}, 'mm/dd/yyyy HH:MM');
d16=datenum(D{16}, 'dd:HH:MM:ss');

% D = {d1,d2,D{3}, D{4}, ...
%     D{5}, D{6}, D{7}, D{8},D{9}, D{10}, D{11}, D{12},D{13}, ...
%     D{14}, D{15}, d16, D{17}, D{18}, ...
%     D{19}, D{20},D{21}, D{22},D{23}, D{24},D{25}, D{26},D{27}, D{28}};


D = {flipud(d1),flipud(d2),flipud(D{3}), flipud(D{4}), ...
    flipud(D{5}), flipud(D{6}), flipud(D{7}), flipud(D{8}), flipud(D{9}), flipud(D{10}), flipud(D{11}), flipud(D{12}), flipud(D{13}), ...
    flipud(D{14}), flipud(D{15}), flipud(d16), flipud(D{17}), flipud(D{18}), ...
    flipud(D{19}), flipud(D{20}), flipud(D{21}), flipud(D{22}), flipud(D{23}), flipud(D{24}), flipud(D{25}), flipud(D{26}), flipud(D{27}), flipud(D{28})};


% structure of the file
%
%
% Open Date,Close Date,Symbol,Action,
% Lots,SL,TP,Open Price,Close Price,Commission,Swap,Pips,Profit,
% Comment,Magic Number,Duration (DD:HH:MM:SS),Profitable(%),Profitable(time duration),
% Drawdown,Risk:Reward,Max(pips),Max(EUR),Min(pips),Min(EUR),Entry Accuracy(%),Exit Accuracy(%),ProfitMissed(pips),ProfitMissed(EUR)%
%
% 10/31/2013 12:48,10/31/2013 13:44,EURUSD,Buy,
% 1.00,1.36414,1.36644,1.36622,1.36409,0.0000,0.0000,-21.3,-156.15,
% "commento",1943642475,00:00:56:26,0.0,0s,
% 29.8,29.85,0.0,0.0,-29.8,-218.434,0.0,28.5,-21.30,-156.13

l=length(D{12});
outputFxbookDemo=zeros(l,8);
Dx=zeros(l,1);
Dxminutes=zeros(l,1);
nCandelotto=zeros(l,1);
direction=zeros(l,1);

% calculate the real time0
% dateFirstOperationNum=D{2}(1);
% dateFirstOperation=datestr(dateFirstOperationNum, 'mm/dd/yyyy HH:MM');
% dateFirstOperationSplitted=regexp(dateFirstOperation, '[ ]', 'split');
% dayFirstOperation=dateFirstOperationSplitted(1);
% timeZero='00:00';
% dateZero=strcat(dayFirstOperation(1),{' '},timeZero);
% dateZeroNum=datenum(dateZero, 'mm/dd/yyyy HH:MM');
dateZeroNum=dateZeroCalculator (D{2}(1));

for i = 1: l
    Dx(i)=abs(dateZeroNum-D{2}(i));
    Dxminutes(i)=Dx(i)*24*60;
    nCandelotto(i)=floor(Dxminutes(i)/5)+1;
    if strcmp(D{4}(i), 'Buy')
        direction(i)=1;
    else
        direction(i)=-1;
    end
end

outputFxbookDemo(:,1)=nCandelotto;
outputFxbookDemo(:,2)=D{8};        % opening price
outputFxbookDemo(:,3)=D{9};        % closure price
outputFxbookDemo(:,4)=D{12};       % returns
outputFxbookDemo(:,5)=direction;   % direction
outputFxbookDemo(:,6)=ones(l,1);   % real
outputFxbookDemo(:,7)=D{1};        % opening date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
outputFxbookDemo(:,8)=D{2};        % closing date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')



%calculate difference between dated in seconds
%
%datenum('2013-02-21T00:39:19Z','yyyy-mm-ddTHH:MM:ss')-datenum('2013-02-21T00:34:19Z','yyyy-mm-ddTHH:MM:ss')
%ans*24*60*60

% tornare indietro alla forma data
%d2=datestr(Df{2}, 'mm/dd/yyyy HH:MM')


% useful commands
%
%outputDemo = csvread(Fullname);
%outputDemo = readtable(Fullname);

%t = fileread(Fullname);
%outputDemo = str2num(t);

%outputDemo=dlmread(Fullname, ',', r, c);
%r=0;
%c=0;



end

