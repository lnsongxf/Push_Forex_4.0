% Algo_ale_02 test usando 239k punti a 1minuto da EURUSD ...2015 (~166gg)
% LOGICA: fa 2 smoothing e quando si incrociano apre nella direzione dello smooth minore
% lead = 2  , lag = 20
% suggestedTP = 5*stdevLag , suggestedSL = 1*stdevLag
% spread fisso a 1pips
% capitale iniziale 10k , leva 10
% finestra di storico di 100 dati
% testo in funzione della timescale considerata

%% timescale 1 minuto:

% clear all;
bkt_Algo1min=bktOffline;
bkt_Algo1min=bkt_Algo1min.spin('Algo_Ale_02','EURUSD',100,'EURUSD_smallsample2014_2015.csv',1,1,1,10000,10);
bkt_Algo1min.performance


% %% timescale 2 minuti:
% 
% % clear all;
% bkt_Algo2min=bktOffline;
% bkt_Algo2min=bkt_Algo2min.spin('Algo_Ale_02','EURUSD',100,'EURUSD_smallsample2014_2015.csv',1,2,1,10000,10);
% bkt_Algo2min.performance

% 
% %% timescale 5 minuti:
% 
% %clear all;
% bkt_Algo5min=bktOffline;
% bkt_Algo5min=bkt_Algo5min.spin('Algo_Ale_02','EURUSD',100,'EURUSD_smallsample2014_2015.csv',1,5,1,10000,10);
% bkt_Algo5min.performance
% 
% %% timescale 6 minuti:
% 
% %clear all;
% bkt_Algo6min=bktOffline;
% bkt_Algo6min=bkt_Algo6min.spin('Algo_Ale_02','EURUSD',100,'EURUSD_smallsample2014_2015.csv',1,6,1,10000,10);
% bkt_Algo6min.performance


% %% timescale 10 minuti:
% 
% %clear all;
% bkt_Algo10min=bktOffline;
% bkt_Algo10min=bkt_Algo10min.spin('Algo_Ale_02','EURUSD',100,'EURUSD_smallsample2014_2015.csv',1,10,1,10000,10);
% bkt_Algo10min.performance
% 
% 
% %% timescale 20 minuti:
% 
% %clear all;
% bkt_Algo20min=bktOffline;
% bkt_Algo20min=bkt_Algo20min.spin('Algo_Ale_02','EURUSD',100,'EURUSD_smallsample2014_2015.csv',1,20,1,10000,10);
% bkt_Algo20min.performance
% 
% 
% %% timescale 30 minuti:
% 
% %clear all;
% bkt_Algo30min=bktOffline;
% bkt_Algo30min=bkt_Algo30min.spin('Algo_Ale_02','EURUSD',100,'EURUSD_smallsample2014_2015.csv',1,30,1,10000,10);
% bkt_Algo30min.performance

% %% timescale 1 ora:
% 
% %clear all;
% bkt_Algo60min=bktOffline;
% bkt_Algo60min=bkt_Algo60min.spin('Algo_Ale_02','EURUSD',100,'EURUSD_smallsample2014_2015.csv',1,60,1,10000,10);
% bkt_Algo60min.performance
% 
% % timescale 2 ore:
% 
% %clear all;
% bkt_Algo120min=bktOffline;
% bkt_Algo120min=bkt_Algo120min.spin('Algo_Ale_02','EURUSD',100,'EURUSD_smallsample2014_2015.csv',1,120,1,10000,10);
% bkt_Algo120min.performance


