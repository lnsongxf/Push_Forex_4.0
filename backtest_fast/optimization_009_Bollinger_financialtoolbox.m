%% Fast optimization of Bollinger parameters
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
    
    closeXminsTest = expert.closeVrescaled;
    dateXminsTest = expert.openDrescaled;
    
    expert.rescaleData(hisDataPaperTrad,actTimeScale,newTimeScale);
    
    closeXminsPaperTrad = expert.closeVrescaled;
    dateXminsPaperTrad = expert.openDrescaled;
    
    
end


%% prova semplice

%  bktfast=bkt_fast_009_bollinger_financialtoolbox;
%  bktfast=bktfast.fast_bollinger_financialtoolbox(hisDataTest(:,4),closeXminsTest,dateXminsTest,newTimeScale,cost,8,1,1);

%% Estimate parameters over a range of values
% Puoi cambiare il periodo di lookback N e le stdev per le bande

matrixsize = 30;
R_over_maxDD = nan(matrixsize,matrixsize);

% if matlabpool('size')==0
%     % se da problemi bisogna andar su Parallel-> Manage Cluster Profiles
%     % ed editare il le preferenze per il local
%     matlabpool local 4;  % vecchio comando per parpool
% end

tic
for n = 5:30
    
    display(['n =', num2str(n)]);
    
    for nstd = 1:5
        
%         display(['n =', num2str(n),' nstd = ',  num2str(nstd)]);
        
        bktfast=bkt_fast_009_bollinger_financialtoolbox;
        bktfast=bktfast.fast_bollinger_financialtoolbox(hisDataTest(:,4),closeXminsTest,dateXminsTest,newTimeScale,cost,n,nstd,0);
        
        if bktfast.indexClose>20
            
        p = Performance_05;
        performance = p.calcSinglePerformance('Bollinger_financialtoolbox','bktWeb',cross,newTimeScale,0,10000,10,bktfast.outputbkt,0);
        display(['pipsEarned = ', num2str(performance.pipsEarned),'; maxdd = ',  num2str(abs(performance.maxDD)), '; numOperaz = ', num2str(bktfast.indexClose) ...
                        '; avg.pips/operaz = ', num2str( (performance.pipsEarned/ bktfast.indexClose) ) ]);    
        R_over_maxDD(n,nstd) = performance.pipsEarned / abs(performance.maxDD);
        
        end
        
    end
end
toc

% matlabpool close;

%visualizza i risultati come surface plot
sweepPlot_BKT_Fast(R_over_maxDD)



%% Plot best performance from Test
% occhio che ind2sub deve prender come primo parametro la lunghezza della
% matrice dei risultati, e che lavora solo su matrici quadrate

 [~, bestInd] = max(R_over_maxDD(:)); % (Linear) location of max value
 [bestN, bestNSTD] = ind2sub(matrixsize, bestInd); % Lead and lag at best value
 
 display(['bestN =', num2str(bestN),' bestNSTD =', num2str(bestNSTD)]);
 
 bktfastTest=bkt_fast_009_bollinger_financialtoolbox;
 bktfastTest=bktfastTest.fast_bollinger_financialtoolbox(hisDataTest(:,4),closeXminsTest,dateXminsTest,newTimeScale,cost,bestN, bestNSTD,1);
 
 p = Performance_05;
 performanceTest = p.calcSinglePerformance('Bollinger_financialtoolbox','bktWeb',cross,newTimeScale,0,10000,10,bktfastTest.outputbkt,0);

risultato = performanceTest.pipsEarned / abs(performanceTest.maxDD);

figure
plot(cumsum(bktfastTest.outputbkt(:,4)))
title(['Test Best Result, Final R over maxDD = ',num2str( risultato) ])

%% now the final check using the Paper Trading

bktfastPaperTrading=bkt_fast_009_bollinger_financialtoolbox;
bktfastPaperTrading=bktfastPaperTrading.fast_bollinger_financialtoolbox(hisDataPaperTrad(:,4),closeXminsPaperTrad,dateXminsPaperTrad,newTimeScale,cost,bestN,bestNSTD,0);

p = Performance_05;
performancePaperTrad = p.calcSinglePerformance('Bollinger_financialtoolbox','bktWeb',cross,newTimeScale,0,10000,10,bktfastPaperTrading.outputbkt,1);
risultato = performancePaperTrad.pipsEarned / abs(performancePaperTrad.maxDD);

figure
plot(cumsum(bktfastPaperTrading.outputbkt(:,4)))
title(['Paper Trading Result, Final R over maxDD = ',num2str( risultato) ])

