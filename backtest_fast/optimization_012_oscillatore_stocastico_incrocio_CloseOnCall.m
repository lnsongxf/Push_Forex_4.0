%% Fast optimization of stochastic oscillator
% cambia i parametri in input qui sotto o fallo girare csi com'è

% close all
% clear all
% 

%annualScaling = sqrt(250);
%annualScaling = sqrt(360000);

%out=importdata('table.csv',',',1);
%adjCl=out.data(:,6);

%% Initial parameters

cross = 'EURUSD';
actTimeScale = 1;
newTimeScale = 30;
cost = 1; % spread

%% Input data:

% % Import the data with dates as 6th columns
% [~, ~, raw] = xlsread('C:\Users\lory\Documents\GitHub\Push_Forex_4.0\EURUSD_2012_2015_withDate_corretto.csv','EURUSD_2012_2015_withDate_corre');
% % Replace non-numeric cells with 0.0
% R = cellfun(@(x) ~isnumeric(x) || isnan(x),raw); % Find non-numeric cells
% raw(R) = {0.0}; % Replace non-numeric cells
% % Create output variable
% hisDataRaw = cell2mat(raw);
% hisDataRaw(:,1:4)=hisDataRaw(:,1:4)*10000;
% % Clear temporary variables
% clearvars raw R;


hisDataRaw=load('EURUSD_2012_2015.csv');
%hisDataRaw=load('EURUSD_smallsample2014_2015.csv');

%% check historical

% remove lines with no data (holes)
hisData = hisDataRaw( (hisDataRaw(:,1) ~=0), : );

[r,c] = size(hisData);


% includi colonna delle date se non esiste nel file di input
if c == 5
    
    hisData(1,6) = datenum('01/01/2015 00:00', 'mm/dd/yyyy HH:MM');
    
    for j = 2:r;
        hisData(j,6) = hisData(1,6) + ( (actTimeScale/1440)*(j-1) );
    end
    
end

%% Split historical into testdata for optimization and paper trading

% dividi lo storico in test per ottimizzare l'algo e paper trading
% (75% dello storico è Test, l'ultimo 25% paper trading)
rTest = floor(r*0.75);
hisDataTest = hisData(1:rTest,:);
hisDataPaperTrad = hisData(rTest+1:end,:);


% riscala temporalmente se richiesto
if newTimeScale > 1
    
    expert = TimeSeriesExpert_11;
    
    expert.rescaleData(hisData,actTimeScale,newTimeScale);
    
    newHisData(:,1) = expert.openVrescaled;
    newHisData(:,2) = expert.maxVrescaled;
    newHisData(:,3) = expert.minVrescaled;
    newHisData(:,4) = expert.closeVrescaled;
    newHisData(:,5) = expert.volrescaled;
    newHisData(:,6) = expert.openDrescaled;
    
    
    expert.rescaleData(hisDataTest,actTimeScale,newTimeScale);
    
    newHisDataTest(:,1) = expert.openVrescaled;
    newHisDataTest(:,2) = expert.maxVrescaled;
    newHisDataTest(:,3) = expert.minVrescaled;
    newHisDataTest(:,4) = expert.closeVrescaled;
    newHisDataTest(:,5) = expert.volrescaled;
    newHisDataTest(:,6) = expert.openDrescaled;
    
    
    expert.rescaleData(hisDataPaperTrad,actTimeScale,newTimeScale);
    
    newHisDataPaperTrad(:,1) = expert.openVrescaled;
    newHisDataPaperTrad(:,2) = expert.maxVrescaled;
    newHisDataPaperTrad(:,3) = expert.minVrescaled;
    newHisDataPaperTrad(:,4) = expert.closeVrescaled;
    newHisDataPaperTrad(:,5) = expert.volrescaled;
    newHisDataPaperTrad(:,6) = expert.openDrescaled;
    
    
end


%% prova semplice

%  bktfast=bkt_fast_012_oscillatore_stocastico_incrocio_CloseOnCall;
%  bktfast=bktfast.fast_oscillatore_stocastico(hisDataTest(:,4),newHisDataTest,5,3,newTimeScale,cost,10,10,1);
 
%% Estimate parameters over a range of values
% Puoi cambiare i TP e SL consigliati
% oppure la lunghezza di lookback nperiods

matrixsize = 20;
R_over_maxDD = nan(matrixsize,matrixsize);


tic
for n = 3:18
    
    display(['n =', num2str(n)]);
    
    for m = n+2:20
    
    
    bktfast=bkt_fast_012_oscillatore_stocastico_incrocio_CloseOnCall;
    bktfast=bktfast.fast_oscillatore_stocastico(hisDataTest(:,4),newHisDataTest,m,n,newTimeScale,cost,10,10,0);
    
    p = Performance_05;
    performance = p.calcSinglePerformance('oscillatore_stocastico','bktWeb',cross,newTimeScale,0,10000,10,bktfast.outputbkt,0);
    
    R_over_maxDD(n,m) = performance.pipsEarned / abs(performance.maxDD);

    end
    
end
toc

%visualizza i risultati come surface plot
figure
sweepPlot_BKT_Fast(R_over_maxDD)



%% Plot best performance from Test
% occhio che ind2sub deve prender come primo parametro la lunghezza della
% matrice dei risultati, e che lavora solo su matrici quadrate

 [~, bestInd] = max(R_over_maxDD(:)); % (Linear) location of max value
 [bestN, bestM] = ind2sub(matrixsize, bestInd); % Lead and lag at best value
 
 display(['bestDperiods =', num2str(bestN),' bestKperiods =', num2str(bestM)]);

bktfastTest=bkt_fast_012_oscillatore_stocastico_incrocio_CloseOnCall;
bktfastTest=bktfastTest.fast_oscillatore_stocastico(hisDataTest(:,4),newHisDataTest,bestM,bestN,newTimeScale,cost,10,10,0);

p = Performance_05;
performanceTest = p.calcSinglePerformance('oscillatore_stocastico','bktWeb',cross,newTimeScale,0,10000,10,bktfastTest.outputbkt,0);

risultato = performanceTest.pipsEarned / abs(performanceTest.maxDD);

figure
plot(cumsum(bktfastTest.outputbkt(:,4)))
title(['Test Best Result, Final R over maxDD = ',num2str( risultato) ])


% pD = PerformanceDistribution_03;
% obj.performanceDistribution = pD.calcPerformanceDistr('oscillatore_stocastico','bktWeb',cross,newTimeScale,0,bktfastTest.outputbkt,hisDataTest,newHisDataTest,15,10,10,5);          


%% now the final check using the Paper Trading

bktfastPaperTrading=bkt_fast_012_oscillatore_stocastico_incrocio_CloseOnCall;
bktfastPaperTrading=bktfastPaperTrading.fast_oscillatore_stocastico(hisDataPaperTrad(:,4),newHisDataPaperTrad,bestM,bestN,newTimeScale,cost,10,10,0);

p = Performance_05;
performancePaperTrad = p.calcSinglePerformance('oscillatore_stocastico','bktWeb',cross,newTimeScale,0,10000,10,bktfastPaperTrading.outputbkt,0);
risultato = performancePaperTrad.pipsEarned / abs(performancePaperTrad.maxDD);

figure
plot(cumsum(bktfastPaperTrading.outputbkt(:,4)))
title(['Paper Trading Result, Final R over maxDD = ',num2str( risultato) ])

