Push_Forex_4.0
==============

Build Matlab Algos

Architettura di Sistema
L’architettura di sistema e’ composta da un server che smista i messaggi tra i brokers(Alpari, ActivTrades, etc..) e i clients (Algo1, Algo2, Algo3). Attualmente possiamo utilizzare solo MT4 come software per i Brokers e Matlab come software per i clients. In futuro inseriremo anche Python, R,  Java etc.. per fare girare gli algoritmi attraverso ulteriori linguaggi di programmazione e il FIX protocol per utilizzare anche ulteriori Brokers come ad esempio Bloomberg. 
figura 1: Architettura FX Pub/Sub





Protocollo di comunicazione
Come illustrato nella figura 1 la comunicazione tra i Clients e i Brokers avviene attraverso un concetto di 
“Publish/Subscribe”.
Nella fase di Subscribe si definisce un Topic name che verrà utilizzato per filtrare i messaggi di proprio interesse. Ogni volta qualcuno invierà un messaggio sul topic specificato, il messaggio sarà recapitato dall’utilizzatore che aveva settato in precedenza questo specifico Topic Name.  Ad esempio, idealmente un cliente setta il topic name=“case@rosse”, quest’ultimo riceverà tutti i messaggi contenenti updates su tutte le case di colore rosso.
Nella fase di Publish si definisce anche in questo caso un Topic name. A differenza della fase di Subscribe il Topic name verrà utilizzato per inviare messaggi esclusivamente su questo Topic name. Ad esempio,  un publisher setta topic name=case@rosse; In questo caso tutti messaggi che il publisher invierà con questo topic name verranno ricevuti esclusivamente da tutti i listeners che in ricezione avevano settato in precedenza topic name= case@rosse.

Dopo questo breve excursus entriamo nel dettaglio della logica di messaggistica utilizzata da MT4 e Matlab.
Di seguito si riportano i gli steps principali nella comunicazione MT4-Matlab:
Quando si sposta un EA/indicatore su un particolare chart (ES:EURUSD), in automatico quest’ultimo invia un messaggio di creazione di un nuovo topic al Server Node. Nel caso specifico riportato nella figura 1 il topic e il messaggio utilizzati da MT verso il Server Node saranno rispettivamente:
Topic: NEWTOPICQUOTES
Message: MT4@ALPARI_1@REALTIMEQUOTES
In questo caso, MT sta dicendo al server Node di creare il nuovo topic di ascolto: MT4@ALPARI_1@REALTIMEQUOTES.

Il secondo step e’ inviare da MT4 al Server Node un set di History Quotes per ogni Time frame di interesse (il time frame dipende dal chart sul quale e’ attaccato l’EX/indicatore). Questo step si concretizza con i seguente messaggio inviato da MT4 al Server Node:
Topic: MT4@ALPARI_1@REALTIMEQUOTES
Message: EURUSD@m1@bid_t0,ask_t0,time_t0.volume_t0$bid_t1,ask_t1,time_t1,volume_t1$……
In questo modo, il Server Node memorizzerà per il time frame 1m(1 minuto) una serie di valori nel formato bid,ask,time,volume.
Il terzo step e’ iniziare ad inviare al Server Node updates periodici per il cross EURUSD. In questo caso ogni volta MT avrà a disposizione un nuovo dato realtime sul cross EURUSD lo invierà al Server Node attraverso il seguente messaggio:
Topic: MT4@ALPARI_1@REALTIMEQUOTES
Message: EURUSD@m1@bid,ask,time.volume
In questo modo il Server Node aggiornerà ogni time-frame array (1m, 5m , 10m, 1h, 1d, etc..) con il nuovo valore
A questo punto il client Matlab dovrà iniziare ad ascoltare le Quotes che il Server Node opportunamente invierà ogni qualvolta avrà un nuovo dato a disposizione per ogni differente Broker, Cross e Time-frame.  
Pertanto, all’interno del file matlab-zmq/example/Algo/configListeners.txt potete configurare i Topics di interesse dai quali si desidera ricevere gli update dei valori. In questo caso, un esempio de file configListeners.txt potrebbe essere:
TIMEFRAMEQUOTE@MT4@ALPARI_1@EURUSD@m1@v10 —> MT4, broker Alpari_1, Cross EURUSD, valori ad un 1 minuto, ultimi 10 valori storici
TIMEFRAMEQUOTE@MT4@ALPARI_1@EURGBP@m5@v40 —> MT4, broker Alpari_1, Cross EURGBP, valori a 5 minuti, ultimi 40 valori storici
Allo startup dell’Algoritmo (matlab-zmq/example/Algo/StartAlgo.m), Matlab leggerà il file di configurazione configListeners.txt e settera i topics di ascolto
In questo caso, ogni volta Matlab riceverà un nuovo messaggio su uno qualsiasi di questi due topics, il messaggio sara’ inoltrato all’algoritmo.m ( ES: matlab-zmq/example/Algo/AlgoTest.m ). 
Lo step 5 e’ necessario affinché Matlab riceva gli update sullo stato delle operazioni che invierà al Broker. Per stato si intende -1 se non e’ riuscito ad effettuare l’operazione o 1 nel caso l’operazione sia andata a buon fine
Pertanto, all’interno del file matlab-zmq/example/Algo/configListeners.txt potete configurare i Topics di interesse dai quali si desidera ricevere gli update sullo stato delle operazione eseguite da MT. In questo caso, un esempio de file configListeners.txt potrebbe essere:
MATLAB@111@EURUSD@STATUS —> Matlab client, identificativo dell’algoritmo 111, Cross EURUSD
MATLAB@111@EURGBP@STATUS —> Matlab client, identificativo dell’algoritmo 111, Cross EURGBP
Lo step 6 e 7 e’ necessario affinché Matlab possa inviare al Broker le operazione da eseguire. In questo caso Matlab dovrà’ inviare al Server Node una richiesta di creazione dei seguenti topic: MATLAB@111@EURUSD@OPERATIONS e MATLAB@111@EURGBP@OPERATIONS
Per ottenere che il Server Node crei questi due 2 nuovi topics e’ necessario che Matlab invii al Server Node i seguenti messaggi:
Topic: NEWTOPICFROMSIGNALPROVIDER
Message: MATLAB@111@EURUSD@OPERATIONS
Topic: NEWTOPICFROMSIGNALPROVIDER
Message: MATLAB@111@EURGBP@OPERATIONS

Lo Step 8 e’ necessario affinché' MT possa ascoltare le operazioni di Apertura e Chiusura provenienti da Matlab. In questo caso MT dovrà’ settare i due seguenti topic listeners:
ALGOSOPERATIONLIST (MATLAB@111@EURUSD@OPERATIONS,MATLAB@etc…)
ALGOSSTATUSLIST (MATLAB@111@EURUSD@STATUS)
Attraverso questi 2 topic MT potrà ricevere dal Node js Server la lista dei topics utilizzati da Matlab per inviare le operazioni da eseguire lato MT e la lista dei topics creati da Matlab sui quali MT dovrà inviare un feedback sullo stato delle operazioni eseguite lato MT
Lo Step 9 e’ il momento più importante nel quale l’algoritmo di Matlab decide di inviare un operazione (Close o Open) verso il Broker (MT). In questo caso i messaggi da utilizzare per inviare questa informazione verso il Broker dovranno essere:
Topic: MATLAB@111@EURUSD@OPERATIONS —> algoritmo id 111, Cross EURUSD
Message: ALPARI_1@operation,volume,price,slippage,stop_loss,take_profit,pending_order_expiration
L’ultimo step 10 e’ necessario affinché Matlab riceva lo stato sulle operazioni eseguite lato MT. In questo caso MT invierà un messaggio di feedback verso Matlab nel seguente modo:
Topic: MATLAB@111@EURUSD@STATUS
Message: -1@Error to close the position / 1@Successful Position closed / -1@Error to open the position / 1@Successful Position opened







