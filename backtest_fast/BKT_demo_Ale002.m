%% Fast backtest using two moving averages, similar to Algo Ale_002
% cambia i parametri in input qui sotto o fallo girare csi com'�

% close all
% clear all
% 

%annualScaling = sqrt(250);
%annualScaling = sqrt(360000);

%out=importdata('table.csv',',',1);
%adjCl=out.data(:,6);

%input parameters:

hisData=load('EURUSD_2012_2015.csv');
%hisData=load('EURUSD_smallsample2014_2015.csv');
actTimeScale = 1;
newTimeScale = 30;
cost = 1; % spread



[r,c] = size(hisData);

% includi colonna delle date se non esiste nel file di input
if c == 5
    
    hisData(1,6) = datenum('01/01/2015 00:00', 'mm/dd/yyyy HH:MM');
    
    for j = 2:r;
        hisData(j,6) = hisData(1,6) + ( (actTimeScale/1440)*(j-1) );
    end
    
end

% riscala temporalmente se richiesto
if newTimeScale > 1
    
    expert = TimeSeriesExpert_11;
    expert.rescaleData(hisData,actTimeScale,newTimeScale);
    
    closeXmins = expert.closeVrescaled;
    dateXmins = expert.openDrescaled;
    
end


%% prova semplice
 
%leadlag_Ale002(closeXmins,dateXmins,2,20,cost);
 %[outputmio,iOpen,iClose,jClose,standev,s,lead,lag]  = leadlag_doppiatimescale_Ale002(hisData(:,4),closeXmins,dateXmins,2,20,newTimeScale,cost,1,5);

%% Estimate parameters over a range of values
% Cambia entrambe le frequenze di smoothing per identificare la miglior
% combinazione (lead � lo smoothing veloce, lag lo smoothing lento)

% NOTA: devo ancora modificarlo per fargli usare performance05...

sharpes = nan(10,10);

tic
for n = 1:10 
    for m = 1:10
        
        [sharpes(n,m),~]=leadlag_doppiatimescale_Ale002(hisData(:,4),closeXmins,dateXmins,2,20,newTimeScale,cost,n,m);
        
    end
end
toc

%visualizza i risultati come surface plot
sweepPlotMA(sharpes)

%% Plot best Sharpe ratio
% occhio che ind2sub deve prender come primo parametro la lunghezza della
% matrice sharpes, e che lavora solo su matrici quadrate

 [~, bestInd] = max(sharpes(:)); % (Linear) location of max value
 [bestN, bestM] = ind2sub(10, bestInd); % Lead and lag at best value

[~,outputmio]= leadlag_doppiatimescale_Ale002(hisData(:,4),closeXmins,dateXmins,2,20,newTimeScale,cost,bestN,bestM);

p = Performance_05;
obj.performance = p.calcSinglePerformance('Ale002','bktWeb','EURUSD',newTimeScale,cost,10000,10,outputmio);
