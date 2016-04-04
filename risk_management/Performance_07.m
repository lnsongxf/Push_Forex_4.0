classdef Performance_07 < handle
    
    %%%%%%%%%%%%%%%%%%
    %
    % This class evaluates the Algos performance calculating several
    % parameters like SharpeRatio or DrawDowns.
    % Please before to launch it load the results matrix from bktWeb or demo
    % changing the paths inside the functions:
    % [outputBktWeb]=fromBktWebToMatrix;
    % [outputFxbookDemo]=fromFxbookToMatrix;
    % [outputDB]=fromDatabaseToMatrix(magicNumber);
    % where inputResultsMatrix is the matrix containing the results of the bktWeb or demo:
    %       1 col:  opening stick index
    %       2 col:  opening price
    %       3 col:  closing price
    %       4 col:  earned pips (returns in bkt or excess of returns in demo)
    %       5 col:  direction of opening
    %       6 col:  real parameter (real=0 virtual mode, excluded from evaluation)
    %       7 col:  opening date
    %       8 col:  closing date
    %
    %%%%%%%%%%%%%%%%%%%%%
    
    properties
        
        nameAlgo;
        origin;
        histName;
        period;
        cross;
        freq;
        transCost;
        initialStack;
        leverage;
        inputResultsMatrix;
        marginePerTrade;
        
        SR;
        netReturns_pips;
        netReturns_Euro;
        netReturns_perc;
        pipsEarned;
        EuroEarned;
        percEarned;
        
        dailyNetReturns_pips;
        dailyAveNetReturns;
        ferialNetReturns;
        ferialAveNetReturns;
         
        dailyNetReturns_Euro;
        dailyAveNetReturnsEuro;
        ferialNetReturnsEuro;
        ferialAveNetReturnsEuro;
        
        dailyNetReturns_perc;
        dailyAveNetReturnsEuroPerc;
        ferialNetReturnsEuroPerc;
        ferialAveNetReturnsEuroPerc;

        
        ferialDaysOperation
        daysOperation;
        numOperations;
        latency;
        minLatency;
        maxLatency;
        aveLatency;
        singleOperMinReturn;
        minSingleOperMinReturn;
        maxSingleOperMinReturn;
        aveSingleOperMinReturn;
        
        RR;
        percExRetPos;
        percExRetNeg;
        percWeExRetPos;
        percWeExRetNeg;
        aveExRetPos;
        aveExRetNeg;
        
        drawDown_pips;
        maxDD_pips;
        minDD_pips;
        aveDD_pips;
        
        drawDown_perc;
        maxDD_perc;
        minDD_perc;
        aveDD_perc;
        dailyDrawDown_perc;
        dailyMaxDD_perc;
        dailyMinDD_perc;
        dailyAveDD_perc;
        
        drawDownDuration_nOper;
        maxDDD_nOper;
        minDDD_nOper;
        aveDDD_nOper;       
        drawDownDuration_days;
        maxDDD_days;
        minDDD_days;
        aveDDD_days;
        
    end
    
    
    methods
        
        %% Function to calculate all the performance parameters of a single result matrix
        
        function obj=calcSinglePerformance(obj,nameAlgo_,origin_,histName_,cross_,freq_,transCost_,initialStack_,leverage_,inputResultsMatrix_,plotPerformance)
            
            %
            % DESCRIPTION:
            % -------------------------------------------------------------
            % This function calculates the Performance of the tested Algo
            %
            % INPUT parameters:
            % -------------------------------------------------------------
            % nameAlgo_             ... name of the tested Algo
            % origin_               ... origin of the results (ex: bktWeb, demo, bkt)
            % cross_                ... cross considered (ex: EURUSD)
            % freq_                 ... frequency of data used (ex: 5 mins)
            % transCost_            ... transaction cost (spread)
            % initialStack_         ... starting money
            % leverage_             ... leverage to use in the real Algo
            % inputResultsMatrix_   ... matrix of results coming from the test
            % plotPerformance       ... check variable for plotting (1) or
            %                           not all the calculated Performance
            %                           properties
            %
            % OUTPUT parameters:
            % -------------------------------------------------------------
            %
            %
            %
            % EXAMPLE of use:
            % -------------------------------------------------------------
            % After having created the object with the name: 'objname'
            % objname=Performance_05;
            % objname=objname.calcSinglePerformance('real_17','bktWeb','EURUSD',30,1,1000,10,outputBktWeb,1);
            %
            
            
            if strcmp(origin_,'bktWeb')
                obj.inputResultsMatrix=inputResultsMatrix_;
            elseif strcmp(origin_,'demo')
                obj.inputResultsMatrix=inputResultsMatrix_;
            elseif strcmp(origin_,'bkt')
                obj.inputResultsMatrix=inputResultsMatrix_;
            else
                h=msgbox('please indicate as origin: bktWeb, demo, bkt','WARN','warn');
                waitfor(h)
                return
            end
            
            colour='r';
            
            obj.nameAlgo=nameAlgo_;
            obj.origin=origin_;
            obj.histName=histName_;
            obj.cross=cross_;
            obj.freq=freq_;
            obj.transCost=transCost_;
            obj.initialStack=initialStack_;
            obj.leverage=leverage_;
            obj=obj.SharpeRatio(colour,plotPerformance);
            obj=obj.RicciRatio;
            [obj.drawDown_pips,obj.maxDD_pips,obj.minDD_pips,obj.aveDD_pips,obj.drawDownDuration_nOper,obj.maxDDD_nOper,obj.minDDD_nOper,obj.aveDDD_nOper]=obj.DrawDown(obj.netReturns_pips);
            [obj.dailyDrawDown_perc,obj.dailyMaxDD_perc,obj.dailyMinDD_perc,obj.dailyAveDD_perc,obj.drawDownDuration_days,obj.maxDDD_days,obj.minDDD_days,obj.aveDDD_days]=obj.DrawDown(obj.dailyNetReturns_perc);
            [obj.drawDown_perc,obj.maxDD_perc,obj.minDD_perc,obj.aveDD_perc,~,~,~,~]=obj.DrawDown(obj.netReturns_perc);
            
        end
        
        
        
        %% Function to calculate all the performance parameters
        
        function obj=calcComparedPerformance(obj,nameAlgo_,origin1_,origin2_,cross_,freq_,transCost1_,transCost2_,inputResultsMatrix1_,inputResultsMatrix2_,plotPerformance)
            
            %
            % example of the use:
            % After having created the object with the name: 'objname'
            % objname=objname.calcComparedPerformance('real_17','bktWeb','demo','EURUSD',5,1,0,outputBktWeb,outputDemo);
            %
            
            
            if strcmp(origin1_,'bktWeb')
                obj.inputResultsMatrix=inputResultsMatrix1_;
                c=1;
            elseif strcmp(origin1_,'demo')
                obj.inputResultsMatrix=inputResultsMatrix1_;
                c=2;
            elseif strcmp(origin1_,'bkt')
                obj.inputResultsMatrix=inputResultsMatrix1_;
                c=3;
            else
                h=msgbox('please indicate as origin1: bktWeb, demo, bkt','WARN','warn');
                waitfor(h)
                return
            end
            
            colour='r';
            
            obj.nameAlgo=nameAlgo_;
            obj.origin=origin1_;
            obj.cross=cross_;
            obj.freq=freq_;
            obj.transCost=transCost1_;
            obj=obj.SharpeRatio(colour,plotPerformance);
            obj=obj.RicciRatio;
            obj=obj.DrawDown;
            
            [name]=dateNameCreator(obj.period);
            name2=strcat(name,'_',origin1_,'.mat');
            switch c
                case 1
                    P_bktWeb1=obj; %#ok<NASGU>
                    save(name2,'P_bktWeb1')
                case 2
                    P_demo1=obj; %#ok<NASGU>
                    save(name2,'P_demo1')
                case 3
                    P_bkt1=obj; %#ok<NASGU>
                    save(name2,'P_bkt1')
            end
            
            
            if origin2_ ~= 0
                
                if strcmp(origin2_,'bktWeb')
                    obj.inputResultsMatrix=inputResultsMatrix2_;
                    c=1;
                elseif strcmp(origin2_,'demo')
                    obj.inputResultsMatrix=inputResultsMatrix2_;
                    c=2;
                elseif strcmp(origin2_,'bkt')
                    obj.inputResultsMatrix=inputResultsMatrix2_;
                    c=3;
                else
                    h=msgbox('please indicate as origin2: bktWeb, demo, bkt','WARN','warn');
                    waitfor(h)
                    return
                end
                
                colour='k';
                
                obj.nameAlgo=nameAlgo_;
                obj.origin=origin2_;
                obj.cross=cross_;
                obj.freq=freq_;
                obj.transCost=transCost2_;
                obj=obj.SharpeRatio(colour,plotPerformance);
                obj=obj.RicciRatio;
                obj=obj.DrawDown;
                
                [name]=dateNameCreator(obj.period);
                name2=strcat(name,'_',origin2_,'.mat');
                switch c
                    case 1
                        P_bktWeb2=obj; %#ok<NASGU>
                        save(name2,'P_bktWeb2')
                    case 2
                        P_demo2=obj; %#ok<NASGU>
                        save(name2,'P_demo2')
                    case 3
                        P_bkt2=obj; %#ok<NASGU>
                        save(name2,'P_bkt2')
                end
                
                
            end
            
            
            
        end
        
        %%
        
        
        %% Function to calculate all the performance parameters
        
        function obj=calcPortfolioPerformance(obj,nameAlgo_,origin1_,origin2_,cross_,freq_,transCost1_,transCost2_,inputResultsMatrix1_,inputResultsMatrix2_,plotPerformance)
            
            %
            % example of the use:
            % After having created the object with the name: 'objname'
            % objname=objname.calcComparedPerformance('real_17','bktWeb','demo','EURUSD',5,1,0,outputBktWeb,outputDemo);
            %
            
            
            if strcmp(origin1_,'bktWeb')
                obj.inputResultsMatrix=inputResultsMatrix1_;
                c=1;
            elseif strcmp(origin1_,'demo')
                obj.inputResultsMatrix=inputResultsMatrix1_;
                c=2;
            elseif strcmp(origin1_,'bkt')
                obj.inputResultsMatrix=inputResultsMatrix1_;
                c=3;
            else
                h=msgbox('please indicate as origin1: bktWeb, demo, bkt','WARN','warn');
                waitfor(h)
                return
            end
            
            colour='r';
            
            obj.nameAlgo=nameAlgo_;
            obj.origin=origin1_;
            obj.cross=cross_;
            obj.freq=freq_;
            obj.transCost=transCost1_;
            obj=obj.SharpeRatio(colour,plotPerformance);
            obj=obj.RicciRatio;
            obj=obj.DrawDown;
            
            [name]=dateNameCreator(obj.period);
            name2=strcat(name,'_',origin1_,'.mat');
            switch c
                case 1
                    P_bktWeb1=obj; %#ok<NASGU>
                    save(name2,'P_bktWeb1')
                case 2
                    P_demo1=obj; %#ok<NASGU>
                    save(name2,'P_demo1')
                case 3
                    P_bkt1=obj; %#ok<NASGU>
                    save(name2,'P_bkt1')
            end
            
            
            if origin2_ ~= 0
                
                if strcmp(origin2_,'bktWeb')
                    obj.inputResultsMatrix=inputResultsMatrix2_;
                    c=1;
                elseif strcmp(origin2_,'demo')
                    obj.inputResultsMatrix=inputResultsMatrix2_;
                    c=2;
                elseif strcmp(origin2_,'bkt')
                    obj.inputResultsMatrix=inputResultsMatrix2_;
                    c=3;
                else
                    h=msgbox('please indicate as origin2: bktWeb, demo, bkt','WARN','warn');
                    waitfor(h)
                    return
                end
                
                colour='k';
                
                obj.nameAlgo=nameAlgo_;
                obj.origin=origin2_;
                obj.cross=cross_;
                obj.freq=freq_;
                obj.transCost=transCost2_;
                obj=obj.SharpeRatio(colour,plotPerformance);
                obj=obj.RicciRatio;
                obj=obj.DrawDown;
                
                [name]=dateNameCreator(obj.period);
                name2=strcat(name,'_',origin2_,'.mat');
                switch c
                    case 1
                        P_bktWeb2=obj; %#ok<NASGU>
                        save(name2,'P_bktWeb2')
                    case 2
                        P_demo2=obj; %#ok<NASGU>
                        save(name2,'P_demo2')
                    case 3
                        P_bkt2=obj; %#ok<NASGU>
                        save(name2,'P_bkt2')
                end
                
                
            end
            
            
            
        end
        
        %%
        
        %% Sharpe Ratio Calculation
        
        function obj=SharpeRatio(obj,colour,plotPerformance)
            
            row = find(obj.inputResultsMatrix(:,6));
            returns    = obj.inputResultsMatrix(row,4);
            nOper      = obj.inputResultsMatrix(row,1);    % nOper is the index of the operation
            lots       = obj.inputResultsMatrix(row,9);
            Latency    = obj.inputResultsMatrix(row,10);   % duration of single operation in minutes
            minReturns = obj.inputResultsMatrix(row,11);   % minimum return touched during dingle operation
            
            workingStack=lots.*100000;
            crossFactor=10000;                             % corresponding to 10^x; where x is the number of digits for a specified cross (ex: EURUSD = 10000)
            pip2EuroConversion=workingStack./crossFactor;
            returnsEuro=returns.*pip2EuroConversion;
            transCostEuro=obj.transCost.*pip2EuroConversion;
            NetReturnsPips=returns-obj.transCost;
            NetReturnsEuro=returnsEuro-transCostEuro;
            NetReturnsEuroPerc=(NetReturnsEuro./obj.initialStack).*100;
            obj.marginePerTrade=lots./obj.leverage;
            
            dateFirstOperationNum=obj.inputResultsMatrix(row(1),8);
            dateFirstOperation=datestr(dateFirstOperationNum, 'mm/dd/yyyy HH:MM');
            temp=regexp(dateFirstOperation, '[ ]', 'split');
            firstDay=temp(1);
            dateLastOperationNum=obj.inputResultsMatrix(row(end),8);
            dateLastOperation=datestr(dateLastOperationNum, 'mm/dd/yyyy HH:MM');
            temp=regexp(dateLastOperation, '[ ]', 'split');
            lastDay=temp(1);
            
            obj.period=strcat(dateFirstOperation,{' - '},dateLastOperation);
            
            %d1=datestr(dateFirstOperationNum, 'mm/dd/yyyy HH:MM');
            dateZeroNum=dateZeroCalculator (dateFirstOperationNum);
            %d2=datestr(dateZeroNum, 'mm/dd/yyyy HH:MM');
            deltaZeroCandelotti=(dateFirstOperationNum-dateZeroNum)*24*60/obj.freq;
            
            lr=length(nOper);
            
            day0=nOper(1)-deltaZeroCandelotti;
            tempDay= (((nOper-day0)*obj.freq)./60)./24;
            day = floor(tempDay)+1;
            
            daysOper=day(end);
            dailyNetReturns=zeros(day(end),1);
            dailyNetReturnsEuro=zeros(day(end),1);
            dailyNetReturnsEuroPerc=zeros(day(end),1);
            numOper=length(returns);
            dailyNumOper=zeros(day(end),1);
            
            
            if daysOper<1
                h=msgbox('insert a BKT longer than 1 day','WARN','warn');
                waitfor(h)
                return
            end
            
            actDay=1;
            for i=1:lr
                if day(i) == actDay
                    dailyNetReturns(actDay)=dailyNetReturns(actDay)+NetReturnsPips(i);
                    dailyNetReturnsEuro(actDay)=dailyNetReturnsEuro(actDay)+NetReturnsEuro(i);
                    dailyNetReturnsEuroPerc(actDay)=dailyNetReturnsEuroPerc(actDay)+NetReturnsEuroPerc(i);
                    dailyNumOper(actDay)=dailyNumOper(actDay)+1;
                else
                    actDay=day(i);
                    dailyNetReturns(actDay)=dailyNetReturns(actDay)+NetReturnsPips(i);
                    dailyNetReturnsEuro(actDay)=dailyNetReturnsEuro(actDay)+NetReturnsEuro(i);
                    dailyNetReturnsEuroPerc(actDay)=dailyNetReturnsEuroPerc(actDay)+NetReturnsEuroPerc(i);
                    dailyNumOper(actDay)=dailyNumOper(actDay)+1;
                end
            end
            
            [~,~,obj.ferialNetReturns]= find(dailyNetReturns);
            [~,~,obj.ferialNetReturnsEuro]= find(dailyNetReturnsEuro);
            [~,~,obj.ferialNetReturnsEuroPerc]= find(dailyNetReturnsEuroPerc);
            
            obj.netReturns_pips      = NetReturnsPips;
            obj.netReturns_Euro      = NetReturnsEuro;
            obj.netReturns_perc      = NetReturnsEuroPerc;
            
            obj.dailyNetReturns_pips = dailyNetReturns;
            obj.dailyNetReturns_Euro = dailyNetReturnsEuro;
            obj.dailyNetReturns_perc = dailyNetReturnsEuroPerc;
            
            obj.ferialAveNetReturns=mean(obj.ferialNetReturns(:));
            obj.dailyAveNetReturns=mean(dailyNetReturns(:));
            obj.ferialAveNetReturnsEuro=mean(obj.ferialNetReturnsEuro(:));
            obj.dailyAveNetReturnsEuro=mean(dailyNetReturnsEuro(:));
            obj.ferialAveNetReturnsEuroPerc=mean(obj.ferialNetReturnsEuroPerc(:));
            obj.dailyAveNetReturnsEuroPerc=mean(dailyNetReturnsEuroPerc(:));
            
            obj.daysOperation=daysOper;
            obj.ferialDaysOperation    = length(obj.ferialNetReturns);
            obj.numOperations          = numOper;
            obj.latency                = Latency;
            obj.minLatency             = min(Latency(:));
            obj.maxLatency             = max(Latency(:));
            obj.aveLatency             = mean(Latency(:));
            obj.singleOperMinReturn    = minReturns;
            obj.minSingleOperMinReturn = min(minReturns(:));
            obj.maxSingleOperMinReturn = max(minReturns(:));
            obj.aveSingleOperMinReturn = mean(minReturns(:));
            
            obj.pipsEarned=sum(NetReturnsPips);
            obj.EuroEarned=sum(NetReturnsEuro);
            obj.percEarned=sum(NetReturnsEuroPerc);
            
            benchmark=0.02/252;
            ferialExReturns=obj.ferialNetReturnsEuroPerc-benchmark;
            ferialAveExReturns=mean(ferialExReturns);
            ferialStdExReturns=std(ferialExReturns);
            obj.SR=sqrt(252)*ferialAveExReturns/ferialStdExReturns;
            
            ProfitLossPips=cumsum(NetReturnsPips);
            ProfitLossEuro=cumsum(NetReturnsEuro);
            
            
            if plotPerformance ==1
                %figure
                
                startDate = datenum(firstDay);
                endDate = datenum(lastDay);
                xDataDays  = linspace(startDate,endDate,daysOper);
                xDataNoper = 1:numOper;
                lin1=zeros(numOper);
                lin2=zeros(daysOper);
                
                %cLine=strcat('-',colour);
                cLine=colour;
                cCurve=colour;
                
                
                % top panel: plot of cumulative returns in pips
                % bottom panel: plot of latency in minutes of single
                % operation and of minimum returns (in pips) per operation
                figure
                s(1)=subplot(2,1,1);
                plot(xDataNoper,ProfitLossPips,cLine);
                title('cumulative Excess of Returns per operation in pips');
                %axis([0 numOper+2 min(PL)-5 max(PL)+5]);
                hold on
                plot(lin1,'-c');
                
                s(2)=subplot(2,1,2);
                plotyy(xDataNoper,Latency,xDataNoper,minReturns);
                legend('latency (mins)','min returns');
                title('latency of single operation in minutes + min returns');
                
                linkaxes(s,'x');
                
                % frequency histogram of the latency
                [latn,xlatn]=hist(Latency,20);
                figure
                subLat(1) = subplot(2,1,1);
                plot(xlatn,cumsum(latn)/sum(latn));
                title('cdf of the latency (in mins)')
                subLat(2) = subplot(2,1,2);
                bar(xlatn,latn/sum(latn));
                title('frequency histogram of the latency (in mins)')
                
                linkaxes(subLat,'x');
                
                % frequency histogram of the lacency, split in won and lost operations
                [latplus,xlatplus]=hist( Latency(find(returns>0)) );
                figure
                subl(1) = subplot(2,2,1);
                plot(xlatplus,cumsum(latplus)/sum(latplus));
                title('cdf of the latency (in mins), won operations')
                subl(3) = subplot(2,2,3);
                bar(xlatplus,latplus/sum(latplus));
                title('frequency histogram of latency, won operations')
                [latlost,xlatlost]=hist( Latency(find(returns<0)) );
                subl(2) = subplot(2,2,2);
                plot(xlatlost,cumsum(latlost)/sum(latlost));
                title('cdf of the latency (in mins), lost operations')
                subl(4) = subplot(2,2,4);
                bar(xlatlost,latlost/sum(latlost));
                title('frequency histogram of latency, lost operations')
                
                linkaxes(subl,'x');
                linkaxes(subl(1:2),'y');
                linkaxes(subl(3:4),'y');

%                 % frequency histogram of latency, ratio between won and lost operations
%                 [latplus,~]=hist( Latency( find(returns>0) ), xlatn );
%                 [latlost,~]=hist( Latency( find(returns<0) ), xlatn );
%                 figure
%                 bar( xlatn , (latplus./latlost) );
%                 title('frequency histogram of latency, ratio won/lost operations')
%                 
%                 % frequency histogram of minimum returns
%                 [n,xout]=hist(minReturns,10);
%                 figure
%                 bar(xout,n/sum(n));
%                 title('frequency histogram of min returns')
                
                % frequency histogram of minimum returns, won operations
                [nplus,xoutplus]=hist( minReturns(find(returns>0)) );
                figure
                subMR(1) = subplot(2,1,1);
                plot(xoutplus,cumsum(nplus)/sum(nplus));
                title('cdf of the min returns, won operations')
                subMR(2) = subplot(2,1,2);
                bar(xoutplus,nplus/sum(nplus));
                title('frequency histogram of min returns, won operations')
                
                linkaxes(subMR,'x');
                
                % plot of cumulative returns in Euro
                figure
                plot(ProfitLossEuro,cLine);
                title('cumulative Excess of Returns per operation in Euro');
                %axis([0 numOper+2 min(PL)-5 max(PL)+5]);
                hold on
                plot(lin1,'-c');
                
                % plot of number of operation per trading day
                figure
                plot(xDataDays,dailyNumOper,cCurve);
                title('number of operations per day');
                hold on
                plot(xDataDays,lin2);
                set(gca,'XTick',xDataDays);
                datetick('x','dd/mm/yyyy HH:MM','keepticks');
                
                % multi-panel plots:
                % - daily excess of returns in pips
                % - cumulative returns per day in pips
                % - daily excess of returns in Euro
                % - cumulative returns per day in Euro
                % - daily Excess of Returns in %
                % - cumulative Excess of Returns per day in %
                
                figure
                
                p(1)=subplot(2,3,1);
                plot(xDataDays,dailyNetReturns,cCurve);
                title('daily Excess of Returns');
                hold on
                plot(xDataDays,lin2);
                
                p(2)=subplot(2,3,4);
                plot(xDataDays,cumsum(dailyNetReturns),cCurve);
                title('cumulative Excess of Returns per day');
                hold on
                plot(xDataDays,lin2);
                
                p(3)=subplot(2,3,2);
                plot(xDataDays,dailyNetReturnsEuro,cCurve);
                title('daily Excess of Returns in Euro');
                hold on
                plot(xDataDays,lin2);
                
                p(4)=subplot(2,3,5);
                plot(xDataDays,cumsum(dailyNetReturnsEuro)+obj.initialStack,cCurve);
                title('cumulative Excess of Returns per day in Euro');
                hold on
                plot(xDataDays,lin2);
                
                p(5)=subplot(2,3,3);
                plot(xDataDays,dailyNetReturnsEuroPerc,cCurve);
                title('daily Excess of Returns in %');
                hold on
                plot(xDataDays,lin2);
                
                p(6)=subplot(2,3,6);
                plot(xDataDays,cumsum(dailyNetReturnsEuroPerc),cCurve);
                title('cumulative Excess of Returns per day in %');
                hold on
                plot(xDataDays,lin2);
                
                set(p,'XTick',xDataDays);
                for i=1:6
                    datetick(p(i),'x','dd/mm/yyyy HH:MM','keepticks');
                end
                
            end
            
            
        end
        
        
        %% Ricci Ratio Calculation
        
        function obj=RicciRatio(obj)
            
            indx =  find(obj.inputResultsMatrix(:,6));
            Returns=obj.inputResultsMatrix(indx,4); %#ok<*FNDSB>
            ExReturns=Returns-obj.transCost;
            
            [ip,~,~] = find(ExReturns>0);
            [in,~,~] = find(ExReturns<0);
            
            P=(ExReturns(ip));
            N=(ExReturns(in));
            
            aveP=mean(P);
            aveN=mean(N);
            
            %percentuali performance
            rP=length(P)*100/(length(P)+length(N));
            rN=length(N)*100/(length(P)+length(N));
            
            %percentuali pesate con il guadagno
            rwP=rP*aveP*100/(rP*aveP+rN*abs(aveN));
            rwN=abs(rN*aveN)*100/(rP*aveP+rN*abs(aveN));
            
            %Ricci Ratio: tra -1 e 1
            obj.RR=((aveP*rP)-abs((aveN*rN)))/((aveP*rP)+abs((aveN*rN)));
            
            obj.percExRetPos=rP;
            obj.percExRetNeg=rN;
            obj.percWeExRetPos=rwP;
            obj.percWeExRetNeg=rwN;
            obj.aveExRetPos=aveP;
            obj.aveExRetNeg=aveN;
            
        end
        
        
        
        %% DrawDown calculation
        
        function [drawDown,maxDD,minDD,aveDD,drawDownDuration,maxDDD,minDDD,aveDDD]=DrawDown(obj,excessOfreturns)
            
            PL=cumsum(excessOfreturns);
            
            highWatermark=zeros(size(PL));
            p=zeros(size(PL));
            pp=zeros(size(PL));
            d=zeros(size(PL));
            dd=zeros(size(PL));
                        
            for t=2:length(PL);
                highWatermark(t)=max(highWatermark(t-1),PL(t));
                %drawDown(t)=(1+highWatermark(t))/(1+PL(t))-1;
                d(t)=highWatermark(t)-PL(t);
                
                if (d(t)==0)
                    p(t)=0;
                else
                    p(t)=p(t-1)+1;
                end
            end
            
            
            l=0;
            for i=1:length(d)
                if d(i)==0
                    l=l+1;
                end
                if d(i)> dd(l,1)
                    dd(l,1)=d(i);
                end
            end
            [~,~,drawDown] = find(dd);
            
            k=0;
            for i=1:length(p)
                if p(i)==0
                    k=k+1;
                end
                if p(i)> pp(k,1)
                    pp(k,1)=p(i);
                end
            end
            [~,~,drawDownDuration] = find(pp);

            maxDD=-max(drawDown);
            minDD=-min(drawDown);
            aveDD=-mean(drawDown);            
            maxDDD=max(drawDownDuration);
            minDDD=min(drawDownDuration);
            aveDDD=mean(drawDownDuration);
            
        end
        
        
        
    end
    
    
    
end