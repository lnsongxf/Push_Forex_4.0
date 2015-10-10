%%  REPORT ALGOS

%% 002_leadlag

% Indicatore:            due medie mobili (pesi costanti) lead (N) e lag (M), dove lag è la media lenta (N<M)  

% Prezzi usati:         Chiusure alle mezz'ore e ai minuti

% Segnale compra:   lead va sopra lag => compra long
%                               lag va sopra lead => compra short

% Segnale vendi:        calcola la volatilità quando apre come media su 100
%                               punti prima del abs(P-lag) con P prezzo alle mezz'ore.
%                               Chiude x SL o TP come X volte la volatilità
%                               Chiude usando i prezzi al minuto


%% 003_Bollinger

% Indicatore:            calcola bande di Bollinger from scratch (seguendo E.Chan),
%                             attraverso una moving average (N giorni) con pesi costanti, moving stdev
%                             e relativo zScore

% Prezzi usati:         Chiusure alle mezz'ore e ai minuti

% Segnale compra:   zScore va sotto ad un valore (wApri) => compra long
%                              zScore va sopra a wApri => compra long


% Segnale vendi:        x TP o SL con numero di pips fissi uguali. Chiude usando i
%                               prezzi al minuto

%% 004_delphic_phenomenon

% Indicatore:            https://www.ig.com/it/il-delphic-phenomenon

% Prezzi usati:         Chiusure alle mezz'ore

% Segnale compra:   usa segnale dell'indicatore


% Segnale vendi:    x chiamata quando il prezzo alle mezz'ore re-incrocia la
%                           curva di lead

%% 005_macd

% Indicatore:           Moving Average Convergence Divergence      

% Prezzi usati:         Chiusure alle mezz'ore e ai minuti

% Segnale compra:   usa segnale dell'indicatore


% Segnale vendi:    x TP o SL con numero di pips fissi diversi definiti in input. Chiude usando i
%                             prezzi al minuto

%% 006_rsi

% Indicatore:            relative strength index           

% Prezzi usati:         Chiusure alle mezz'ore e ai minuti

% Segnale compra:   usa segnale dell'indicatore con thresholds di default (30,70)


% Segnale vendi:    x TP o SL con numero di pips fissi uguali. Chiude usando i
%                               prezzi al minuto

%% 007_SMAslope

% Indicatore:            calcola il gradiente di una moving average a "maPeriod" periodi
%                              se il gradiente è maggiore di una threshold
%                              o minore di -threshold compra seguendo il trend

% Prezzi usati:         Chiusure alle mezz'ore e ai minuti

% Segnale compra:   gradiente maggiore di threshold => compra long
%                              gradiente minore di -threshold => compra short


% Segnale vendi:     x TP o SL con numero di pips fissi uguali,
%                            oppure se il trend (alle mezz'ore) cambia segno
%                            Chiude usando i prezzi al minuto

%% 008_supertrend  (CONTROLLA SE IL SORTING DI HIGH E LOW E' NELLA POSIZIONE GIUSTA !!)

% Indicatore:            "supertrend", i.e. controlla massimi e minimi su un periodo e si crea un indicatore 

% Prezzi usati:         matrice (apre,chiude,min,max,date) alle mezz'ore, e chiusure ai minuti

% Segnale compra:   segnale dell'indicatore


% Segnale vendi:    x TP o SL con numero di pips fissi uguali,
%                            oppure se il segnale(alle mezz'ore) si inverte
%                            Chiude usando i prezzi al minuto

%% 009_bollinger_financialtoolbox

% Indicatore:            bande di Bollinger implementate nel financial toolbox, 
%                               con stdev modificabile x definir le bande

% Prezzi usati:         Chiusure alle mezz'ore e ai minuti

% Segnale compra:   prezzo interseca una delle due bande (long se interseca
%                              quella sotto, short x quella sopra)


% Segnale vendi:    x SL a 10pips
%                           oppure se il prezzo tocca la banda opposta
%                            Chiude usando i prezzi al minuto

%% 010_WpR

% Indicatore:            Williams %R con default thresholds (20,80)

% Prezzi usati:         matrice (apre,chiude,min,max,date) alle mezz'ore, e chiusure ai minuti

% Segnale compra:   segnale dell'indicatore


% Segnale vendi:    x TP o SL con numero di pips fissi uguali,
%                            oppure se il segnale(alle mezz'ore) si inverte


%% 011_oscillatore_stocastico

% Indicatore:            oscillatore stocastico direttamente dal financial toolbox, 
%                             https://www.ig.com/it/oscillatore-stocastico-prima-parte

% Prezzi usati:         matrice (apre,chiude,min,max,date) alle mezz'ore, e chiusure ai minuti

% Segnale compra:   segnale dell'indicatore supera un range di default (20,80)


% Segnale vendi:      x TP o SL con numero di pips fissi uguali,
%                            oppure se il segnale(alle mezz'ore) si inverte
%                            Chiude usando i prezzi al minuto


