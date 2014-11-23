
function [outputDB]=fromDatabaseToMatrix(magicNumber)

%%% ATTENTION:
% the input Demo .csv is in a standard format
% fist row is the oldest operation.
%
% magicNuber is the reference code of the Algorithm on MT4
%

filename = '2013_14Oct_15Nov_DB';
filedir = 'C:\Users\Ale\algorithms_RAV\QUANT\_TEST Algos\Demo-BktWeb\';
Fullname  = strcat(filedir, filename,'.csv');

fid1 = fopen(Fullname, 'r');
D = textscan(fid1,'%s%f%f%f%f%f%f%f%f%s%s%f', 'Delimiter', ',', 'HeaderLines', 0);
fclose(fid1);

s1=str2double(D{1});
s2=datenum(D{10}, 'yyyy.mm.dd HH:MM');
s3=datenum(D{11}, 'yyyy.mm.dd HH:MM');


D = [s1,...
    D{2},D{3}, D{4},D{5}, D{6}, D{7}, D{8}, D{9},...
    s2, s3,...
    D{12}];


% structure of the file
% 
% cross,
% ticket,magic,n,open,close,TP price,SL price, direction
% open date, close date
% code
% 
% EURUSD,
% 314954970,-2081673515,1,1.3566,1.3545,1.3568,1.3545,-1,
% 2013.11.01 02:23,2013.11.01 03:20,
% 4264490

l=length(D(:,8));
s=size(D);
row=zeros(s(1),1);
index=D(:,3);
for i = 1: l
    t=index(i);
    if t == magicNumber
        row(i,1)=1;
    else
        row(i,1)=0;
    end
end

k=sum(row);
rowMatrix= repmat(row,1,s(2));
rowMatrix=logical(rowMatrix);
Dn=D(rowMatrix);
Dn=reshape(Dn,k,s(2));

outputDB=zeros(k,8);
Dx=zeros(k,1);
Dxminutes=zeros(k,1);
nCandelotto=zeros(k,1);

dateZeroNum=dateZeroCalculator (Dn(1,11));

for i = 1: k
    Dx(i)=abs(dateZeroNum-Dn(i,11));
    Dxminutes(i)=Dx(i)*24*60;
    nCandelotto(i)=floor(Dxminutes(i)/5)+1;
end

returns=(Dn(:,6)-Dn(:,5)).*Dn(:,9);

outputDB(:,1)=nCandelotto;
outputDB(:,2)=Dn(:,5);        % opening price
outputDB(:,3)=Dn(:,6);        % closure price
outputDB(:,4)=returns;        % returns
outputDB(:,5)=Dn(:,9);        % direction
outputDB(:,6)=ones(k,1);      % real
outputDB(:,7)=Dn(:,10);       % opening date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
outputDB(:,8)=Dn(:,11);       % closing date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')



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

