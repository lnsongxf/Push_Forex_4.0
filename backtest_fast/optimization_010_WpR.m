%% Fast optimization of Williams %R
% cambia i parametri in input qui sotto o fallo girare csi com'è

% close all
% clear all
% 

%annualScaling = sqrt(250);
%annualScaling = sqrt(360000);

%out=importdata('table.csv',',',1);
%adjCl=out.data(:,6);

%input parameters:

%hisData=load('EURUSD_2012_2015.csv');
hisData=load('EURUSD_smallsample2014_2015.csv');
cross = 'EURUSD';
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

% dividi lo storico in test per ottimizzare l'algo e paper trading
% (75% dello storico è Test, l'ultimo 25% paper trading)
rTest = floor(r*0.75);
hisDataTest = hisData(1:rTest,:);
hisDataPaperTrad = hisData(rTest+1:end,:);


% riscala temporalmente se richiesto
if newTimeScale > 1
    
    expert = TimeSeriesExpert_11;
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

% bktfast=bkt_fast_010_WpR;
% bktfast=bktfast.fast_WpR(hisDataTest(:,4),newHisDataTest,11,newTimeScale,cost,10,10,1);

%% Estimate parameters over a range of values
% Puoi cambiare i TP e SL consigliati
% oppure la lunghezza di lookback nperiods

matrixsize = 50;
R_over_maxDD = nan(matrixsize,1);


tic
for n = 3:50
    
    display(['n =', num2str(n)]);
    
    
    bktfast=bkt_fast_010_WpR;
    bktfast=bktfast.fast_WpR(hisDataTest(:,4),newHisDataTest,n,newTimeScale,cost,10,10,0);
    
    p = Performance_05;
    performance = p.calcSinglePerformance('WpR','bktWeb',cross,newTimeScale,0,10000,10,bktfast.outputbkt,0);
    
    R_over_maxDD(n) = performance.pipsEarned / abs(performance.maxDD);
    
    
end
toc

%visualizza i risultati come surface plot
figure
plot(R_over_maxDD)



%% Plot best performance from Test
% occhio che ind2sub deve prender come primo parametro la lunghezza della
% matrice dei risultati, e che lavora solo su matrici quadrate

 [~, bestN] = max(R_over_maxDD(:)); % (Linear) location of max value

 display(['bestN =', num2str(bestN)]);

bktfastTest=bkt_fast_010_WpR;
bktfastTest=bktfastTest.fast_WpR(hisDataTest(:,4),newHisDataTest,bestN,newTimeScale,cost,10,10,0);

p = Performance_05;
performanceTest = p.calcSinglePerformance('WpR','bktWeb',cross,newTimeScale,0,10000,10,bktfastTest.outputbkt,0);

risultato = performanceTest.pipsEarned / abs(performanceTest.maxDD);

figure
plot(cumsum(bktfastTest.outputbkt(:,4)))
title(['Test Best Result, Final R over maxDD = ',num2str( risultato) ])

%% now the final check using the Paper Trading

bktfastPaperTrading=bkt_fast_010_WpR;
bktfastPaperTrading=bktfastPaperTrading.fast_WpR(hisDataPaperTrad(:,4),newHisDataPaperTrad,bestN,newTimeScale,cost,10,10,0);

p = Performance_05;
performancePaperTrad = p.calcSinglePerformance('WpR','bktWeb',cross,newTimeScale,0,10000,10,bktfastPaperTrading.outputbkt,0);
risultato = performancePaperTrad.pipsEarned / abs(performancePaperTrad.maxDD);

figure
plot(cumsum(bktfastPaperTrading.outputbkt(:,4)))
title(['Paper Trading Result, Final R over maxDD = ',num2str( risultato) ])

