classdef Performance_02 < handle
    
    %%%%%%%%%%%%%%%%%%
    %
    % This class evaluates the Algos performance calculating several
    % parameters like SharpeRatio or DrawDowns.
    % Please before to launch it load the results matrix from bktWeb or demo
    % changing the paths inside the functions:
    % [inputResultsMatrix]=fromDemoToMatrix;
    % [inputResultsMatrix]=fromBktWebToMatrix;
    % where inputResultsMatrix is the matrix containing the results of the bktWeb or demo:
    %       1 col:  opening index
    %       2 col:  opening price
    %       3 col:  closing price
    %       4 col:  earned pips (returns in bkt or excess of returns in demo)
    %       5 col:  direction of opening
    %       6 col:  real parameter (real=0 virtual mode, excluded from evaluation
    %       7 col:  opening date
    %       8 col:  closing date
    %
    %%%%%%%%%%%%%%%%%%%%%
    
    properties
        
        nameAlgo;
        origin;
        period;
        cross;
        freq;
        transCost;
        inputResultsMatrix;
        
        SR;
        ferialAveExReturns;
        dailyAveExReturns;
        pipsEarned;
        ferialDaysOperation
        daysOperation;
        numOperations;
        RR;
        percExRetPos;
        percExRetNeg;
        percWeExRetPos;
        percWeExRetNeg;
        aveExRetPos;
        aveExRetNeg;
        minDD;
        maxDD;
        aveDD;
        minDDD;
        maxDDD;
        aveDDD;
    end
    
    
    methods
        
        %% Function to calculate all the performance parameters
        
        function obj=calcPerformance(obj,nameAlgo_,origin_,cross_,freq_,transCost_,inputResultsMatrix_)
            
            %
            % example of the use:
            % After having created the object with the name: 'objname'
            % objname=objname.calcPerformance('real_17','bktWeb','EURUSD',5,1,LCN_17_0_2009_a)
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
            
            obj.nameAlgo=nameAlgo_;
            obj.origin=origin_;
            obj.cross=cross_;
            obj.freq=freq_;
            obj.transCost=transCost_;
            obj=obj.SharpeRatio;
            obj=obj.RicciRatio;
            obj=obj.DrawDown;            
            
        end
        
        %%
        
        
        
        
        %% Sharpe Ratio Calculation
        
        function obj=SharpeRatio(obj)
            
            [row,~,r] = find(obj.inputResultsMatrix(:,4).*obj.inputResultsMatrix(:,6));
            %Returns=floor(r);
            Returns=r;
            [~,~,nOper] = find(obj.inputResultsMatrix(:,1).*obj.inputResultsMatrix(:,6));    % nOper is the index of the operation
            ExReturns=Returns-obj.transCost;
            
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
            dailyExReturns=zeros(day(end),1);
            numOper=length(Returns);
            dailyNumOper=zeros(day(end),1);
            
           
            if daysOper<1
                h=msgbox('insert a BKT longer than 1 day','WARN','warn');
                waitfor(h)
                return
            end
            
            actDay=1;
            for i=1:lr
                if day(i) == actDay
                    dailyExReturns(actDay)=dailyExReturns(actDay)+ExReturns(i);
                    dailyNumOper(actDay)=dailyNumOper(actDay)+1;
                else
                    actDay=day(i);
                    dailyExReturns(actDay)=dailyExReturns(actDay)+ExReturns(i);
                    dailyNumOper(actDay)=dailyNumOper(actDay)+1;
                end
            end
                      
            [~,~,ferialExReturns]= find(dailyExReturns);
            obj.ferialAveExReturns=mean(ferialExReturns(:));
            obj.dailyAveExReturns=mean(dailyExReturns(:));
            ferialStdExReturns=std(ferialExReturns(:));
            obj.daysOperation=daysOper;
            obj.ferialDaysOperation=length(ferialExReturns);
            obj.pipsEarned=sum(ExReturns);
            obj.numOperations=numOper;
            
            obj.SR=sqrt(252)*obj.ferialAveExReturns/ferialStdExReturns;
            
            %figure
            
            startDate = datenum(firstDay);
            endDate = datenum(lastDay);
            xData = linspace(startDate,endDate,daysOper);
            lin1=zeros(numOper);
            lin2=zeros(daysOper);
            
            subplot(4,1,1)
            PL=cumsum(ExReturns);
            plot(PL);
            title('cumulative Excess of Returns per operation');
            axis([0 numOper+2 min(PL)-5 max(PL)+5]);
            hold on
            plot(lin1);
            
            p(1)=subplot(4,1,2);
            plot(xData,dailyNumOper,'-or');
            title('number of operations per day');
            hold on
            plot(xData,lin2);
                       
            p(2)=subplot(4,1,3);
            plot(xData,dailyExReturns,'-or');
            title('daily Excess of Returns');
            hold on
            plot(xData,lin2);
            
            p(3)=subplot(4,1,4);
            plot(xData,cumsum(dailyExReturns),'-or');
            title('cumulative Excess of Returns per day');
            hold on
            plot(xData,lin2);
            
            set(p,'XTick',xData);
            for i=1:3
                datetick(p(i),'x','dd','keepticks');
            end
            
        end
        
        
        %% Ricci Ratio Calculation
        
        function obj=RicciRatio(obj)
            
            [~,~,r] = find(obj.inputResultsMatrix(:,4).*obj.inputResultsMatrix(:,6));
            %Returns=floor(r);
            Returns=r;
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
        
        function obj=DrawDown(obj)
            
            [~,~,r] = find(obj.inputResultsMatrix(:,4).*obj.inputResultsMatrix(:,6));
            %Returns=floor(r);
            Returns=r;
            ExReturns=Returns-obj.transCost;
            
            %l=leverage;
            %iS=initialStock;
            
            %effecrive Stock
            %eS=iS*l;
            %PL=eS+cumsum(Returns);
            
            PL=cumsum(ExReturns);
            
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
            %display(drawDown);
            
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
            %display(drawDownDuration);
            
            
            obj.maxDD=-max(drawDown);
            obj.minDD=-min(drawDown);
            obj.aveDD=-mean(drawDown);
            
            obj.maxDDD=max(drawDownDuration);
            obj.minDDD=min(drawDownDuration);
            obj.aveDDD=mean(drawDownDuration);
            
        end
        
        
    end
    
    
    
end