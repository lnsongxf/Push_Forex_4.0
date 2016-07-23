function [outputWP]=fromWebPageToMatrix(AlgoMagicNumber,newTimeScale, Fullname)

%%% ATTENTION:
% the input Demo .csv is in a standard format
% fist row is the oldest operation.
%
% AlgoMagicNumber is the reference code of the Algorithm on MT4
% newTimeScale is the working time frame of the Algo (ex: 30 mins)
%

%Fullname  = strcat(filedir, filename,'.csv');

fid1 = fopen(Fullname, 'r');
D = textscan(fid1,'%f%f%f%f%f%f%s%s%f%f%f%s%f%f%f%f%s%f%f', 'Delimiter', ',', 'HeaderLines', 0);
fclose(fid1);

s7=datenum(D{7}, 'mm/dd/yyyy HH:MM');
s8=datenum(D{8}, 'mm/dd/yyyy HH:MM');
s12=str2double(D{12});
s17=str2double(D{17});


D = [D{1}, D{2}, D{3}, D{4}, D{5}, D{6},...
    s7, s8, D{9},...
    D{10}, D{11},...
    s12, D{13}, D{14}, D{15}, D{16}, s17, D{18}, D{19}];

% structure of the file
% 1) index of stick , 2) opening price , 3) closing price , 4) returns , 5) direction , 6) real , 
% 7) opening date 'mm/dd/yyyy HH:MM' , 8) closing date ‘mm/dd/yyyy HH:MM', 9) lots set for single operation , 
% 10) duration of single operation , 11) minimum return touched during single operation , 
% 12) cross , 13) SL price , 14) TP price , 15) 0 , 16) 0 , 17) comment , 18) Algo magic number , 19) operation ticket


l=length(D(:,19));
s=size(D);
row=zeros(s(1),1);
index=D(:,18);
for i = 1: l
    t=index(i);
    if t == AlgoMagicNumber
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

outputWP=zeros(k,8);
Dx=zeros(k,1);
Dxminutes=zeros(k,1);
nCandelotto=zeros(k,1);

dateZeroNum=dateZeroCalculator (Dn(1,8));

for i = 1: k
    Dx(i)=abs(dateZeroNum-Dn(i,8));
    Dxminutes(i)=Dx(i)*24*60;
    nCandelotto(i)=floor(Dxminutes(i)/newTimeScale)+1;
end

returns=(Dn(:,3)-Dn(:,2)).*Dn(:,5).*10000;

outputWP(:,1)  = nCandelotto;
outputWP(:,2)  = Dn(:,2);        % opening price
outputWP(:,3)  = Dn(:,3);        % closure price
outputWP(:,4)  = returns;        % returns
outputWP(:,5)  = Dn(:,5);        % direction
outputWP(:,6)  = Dn(:,6);        % real
outputWP(:,7)  = Dn(:,7);        % opening date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
outputWP(:,8)  = Dn(:,8);        % closing date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
outputWP(:,9)  = Dn(:,9);        % lots set for single operation 
outputWP(:,10) = Dn(:,10);       % duration of single operation (latency) 
outputWP(:,11) = Dn(:,11);       % minimum return touched during single operation


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
