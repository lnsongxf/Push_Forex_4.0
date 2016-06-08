
hisData=load('EURUSD_2012_2015.csv');
%hisData=load('EURUSD_smallsample2014_2015.csv');
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


%%

returns = 0;
chunks = 150000;  % lunghezza di ogni chunk al minuto
noptim = floor( length(hisData(:,4)) / chunks ); % numero di ottimizzazioni risultanti

matrixsize = 20;
% parametri iniziali per il primo chunk (non viene ottimizzato)
bestN = 5;
bestNSTD = 1;

display(['nr hours in each chunk =', num2str(chunks/60)]);
display(['nr of optimizations =', num2str(noptim)]);

for i = 0:noptim
    
    display([num2str(i)]);
    R_over_maxDD = nan(matrixsize,matrixsize);
    
    startRow = i*chunks +1;
    stopRow = (i+1)*chunks;
    if ( stopRow > length(hisData(:,4)) )
        stopRow = length(hisData(:,4));
    end
    
    hisDataChunk = hisData(startRow:stopRow,:);
    
    % riscala temporalmente se richiesto
    if newTimeScale > 1
        
        expert = TimeSeriesExpert_11;
        expert.rescaleData(hisDataChunk,actTimeScale,newTimeScale);
        
        closeXmins = expert.closeVrescaled;
        dateXmins = expert.openDrescaled;
        
    end
    
    % risultato dall'ottimizzazione del chunk precedente
    bktfast=bkt_fast_009_bollinger_financialtoolbox;
    bktfast=bktfast.fast_bollinger_financialtoolbox(hisDataChunk(:,4),closeXmins,dateXmins,newTimeScale,cost,bestN,bestNSTD,0);
    returns = cat(1,returns,bktfast.outputbkt(:,4));
    
    
    % calcolo dei parametri da utilizzare nel chunk sucessivo
    for n = 5:20
        
        for nstd = 1:3
            
            bktfast=bkt_fast_009_bollinger_financialtoolbox;
            bktfast=bktfast.fast_bollinger_financialtoolbox(hisDataChunk(:,4),closeXmins,dateXmins,newTimeScale,cost,n,nstd,0);
            
            if bktfast.indexClose > 3
                
                p = Performance_05;
                performance = p.calcSinglePerformance('Bollinger_financialtoolbox','bktWeb',cross,newTimeScale,0,10000,10,bktfast.outputbkt,0);
                %display(['pipsEarned = ', num2str(performance.pipsEarned),'; maxdd = ',  num2str(abs(performance.maxDD)), '; numOperaz = ', num2str(bktfast.indexClose) ...
                %               '; avg.pips/operaz = ', num2str( (performance.pipsEarned/ bktfast.indexClose) ) ]);
                R_over_maxDD(n,nstd) = performance.pipsEarned / abs(performance.maxDD);
                
            end
            
        end
        
    end
    
    % salva i risultati da usare nel chunk sucessivo
    [~, bestInd] = max(R_over_maxDD(:)); % (Linear) location of max value
    [bestN, bestNSTD] = ind2sub(matrixsize, bestInd); % Lead and lag at best value
    
    display(['bestN =', num2str(bestN),' bestNSTD =', num2str(bestNSTD)]);
    
    
end

figure
plot(cumsum(returns))