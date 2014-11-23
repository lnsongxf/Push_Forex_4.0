function [outputBktWeb]=fromBktWebToMatrix

% [outputBktWeb]=fromBktWebToMatrix(result)

%%% NOTE
% 
% 
% 

filename = 'bktWeb_17_14Oct_1Nov';
filedir = 'C:\Users\Ale\algorithms_RAV\QUANT\_TEST Algos\Demo-BktWeb\';
Fullname  = strcat(filedir, filename,'.mat');

tempMatrix = load(Fullname);
matrixWeb=tempMatrix.z_cut;
%matrixWeb=result;



openingDate=strcat(num2str(matrixWeb(:,8)+1),'/',num2str(matrixWeb(:,9)),'/',num2str(matrixWeb(:,7)),{' '},num2str(matrixWeb(:,10)),':',num2str(matrixWeb(:,11)));
closingDate=strcat(num2str(matrixWeb(:,14)+1),'/',num2str(matrixWeb(:,15)),'/',num2str(matrixWeb(:,13)),{' '},num2str(matrixWeb(:,16)),':',num2str(matrixWeb(:,17)));
openingDateNum=datenum(openingDate, 'mm/dd/yyyy HH:MM');
closingDateNum=datenum(closingDate, 'mm/dd/yyyy HH:MM');


l=length(matrixWeb(:,1));
outputBktWeb=zeros(l,8);
Dx=zeros(l,1);
Dxminutes=zeros(l,1);
nCandelotto=zeros(l,1);

dateZeroNum=dateZeroCalculator (closingDateNum(1));

for i = 1: l
    Dx(i)=abs(dateZeroNum-closingDateNum(i));
    Dxminutes(i)=Dx(i)*24*60;
    nCandelotto(i)=floor(Dxminutes(i)/5)+1;
end

outputBktWeb(:,1)=nCandelotto;
outputBktWeb(:,2)=matrixWeb(:,2);        % opening price
outputBktWeb(:,3)=matrixWeb(:,3);        % closing price
outputBktWeb(:,4)=matrixWeb(:,4);        % returns
outputBktWeb(:,5)=matrixWeb(:,5);        % direction
outputBktWeb(:,6)=matrixWeb(:,6);        % real
outputBktWeb(:,7)=openingDateNum;        % opening date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
outputBktWeb(:,8)=closingDateNum;        % closing date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')


end

