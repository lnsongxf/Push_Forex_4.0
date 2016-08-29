classdef PerformanceDistribution_05 < handle
    
    properties
        nameAlgo;
        origin;
        cross;
        nData;
        freq;
        transCost;
        inputResultsMatrix
        HistData1min
        HistDatafreq
        
        rowHistOp
        rowHistpOp
        rowHistnOp
        rowHistCl
        rowHistpCl
        rowHistnCl
        rowRespOp
        rowResnOp
        rowRespCl
        rowResnCl
        win_operations
        lost_operations
        microParamsPos
        microParamsNeg
        macroParamsPos
        macroParamsNeg
    end
    
    methods
        
        %%
        
        function obj=calcPerformanceDistr(obj,nameAlgo_,origin_,cross_,nData_,freq_,transCost_,inputResultsMatrix_,timeSeriesProperties_,HistData_1min_,HistData_freq_,nstep,nstepeq,dimCluster,plotPerDistribution)
            
            %
            % DESCRIPTION:
            % -------------------------------------------------------------
            % This function calculates the Performance of the tested Algo as
            % a function of several microscopic/macroscopic and returns
            % pattern properties.
            % Moreover it allows to plot the operations done on the
            % hystorical price curve.
            %
            % INPUT parameters:
            % -------------------------------------------------------------
            % nameAlgo_             ... name of the tested Algo
            % origin_               ... origin of the results (ex: bktWeb, demo, bkt)
            % cross_                ... cross considered (ex: EURUSD)
            % freq_                 ... frequency of data used (ex: 5 mins)
            % transCost_            ... transaction cost (spread)
            % inputResultsMatrix_   ... matrix of results coming from the test
            % timeSeriesProperties_ ... properties calculated during the
            %                           bkt
            % HistData_1min_        ... 1min-hystorical data correspondent to the period of test
            %                           use the function [outputHyst]=fromRawHystToHistorical
            % HistData_freq_        ... 5mins-hystorical data correspondet to the period of test
            % nstep                 ... number of binnig steps
            % nstepeq               ... pattern of returns: distance
            %                           between a given wrong/correct operation and the next one
            % dimCluster            ... pattern of returns: number of wrong/correct subsequent operations (dimension of cluster)
            %
            % OUTPUT parameters:
            % -------------------------------------------------------------
            %
            %
            %
            % EXAMPLE of use:
            % -------------------------------------------------------------
            % pd=PerformanceDistribution_04;
            % pd=pd.calcPerformanceDistr('real_17','bktWeb','EURUSD',100,5,1,bkt_Algo002.outputBktOffline,bkt_Algo002.timeSeriesProperties,bkt_Algo002.starthisData,bkt_Algo002.newHisData,12,10,10,5)
            %
            
            
            tic
            
            matrix = find(inputResultsMatrix_(:,6));
            obj.inputResultsMatrix=inputResultsMatrix_(matrix,:); %#ok<FNDSB>
            
            obj.nameAlgo=nameAlgo_;
            obj.origin=origin_;
            obj.cross=cross_;
            obj.nData=nData_;
            obj.freq=freq_;
            obj.transCost=transCost_;
            obj.HistData1min=HistData_1min_;
            obj.HistDatafreq=HistData_freq_;
            
            
            returns         = obj.inputResultsMatrix(:,4);
            obj.win_operations  = obj.inputResultsMatrix( (returns>0) , : );
            obj.lost_operations = obj.inputResultsMatrix( (returns<=0) , : );
            
            obj.rowRespOp   = find(returns>0);
            obj.rowResnOp   = find(returns<=0);
            
            date_open       = obj.inputResultsMatrix(:,7);
            date_open_win   = obj.win_operations(:,7);
            date_open_lost  = obj.lost_operations(:,7);
            
            date_close      = obj.inputResultsMatrix(:,8);
            date_close_win  = obj.win_operations(:,8);
            date_close_lost = obj.lost_operations(:,8);
            
            [~,obj.rowHistOp,~] = intersect(obj.HistData1min(:,6), date_open, 'stable');
            [~,obj.rowHistpOp,~] = intersect(obj.HistData1min(:,6), date_open_win, 'stable');
            [~,obj.rowHistnOp,~] = intersect(obj.HistData1min(:,6), date_open_lost, 'stable');
            
            [~,obj.rowHistCl,~] = intersect(obj.HistData1min(:,6), date_close, 'stable');
            [~,obj.rowHistpCl,obj.rowRespCl] = intersect(obj.HistData1min(:,6), date_close_win, 'stable');
            [~,obj.rowHistnCl,obj.rowResnCl] = intersect(obj.HistData1min(:,6), date_close_lost, 'stable');
            
            switch plotPerDistribution
                case 0
                    
                case 1
                    obj=obj.analysisMicroParams(nstep);
                case 2
                    obj=obj.analysisMicroParams(nstep);
                    obj=obj.analysisMacroParams(nstep);
                case 3
                    obj=obj.analysisMicroParams(nstep);
                    obj=obj.analysisMacroParams(nstep);
                    obj=obj.analysisReturnsPattern(nstepeq,dimCluster);
                case 4
                    obj=obj.analysisMicroParams(nstep);
                    obj=obj.analysisMacroParams(nstep);
                    obj=obj.analysisReturnsPattern(nstepeq,dimCluster);
                    obj=obj.plotOperationOnHystorical(timeSeriesProperties_);
            end
            
            toc
            
        end
        
        
        
        %%
        function obj=analysisMicroParams(obj,nstep)
            
            rp=obj.rowHistpOp;
            rn=obj.rowHistnOp;
            
            volumep=obj.HistData1min(rp,5);
            volumen=obj.HistData1min(rn,5);
            stickp=abs(obj.HistData1min(rp,3)-obj.HistData1min(rp,2));
            stickn=abs(obj.HistData1min(rn,3)-obj.HistData1min(rn,2));
            energyp=(0.5.*volumep).*(stickp./obj.freq).^2;
            energyn=(0.5.*volumen).*(stickn./obj.freq).^2;
            
            obj.microParamsPos(:,2)=obj.HistData1min(rp,2);
            obj.microParamsPos(:,3)=obj.HistData1min(rp,3);
            obj.microParamsPos(:,5)=volumep;                                       % volume at opening time
            obj.microParamsPos(:,7)=stickp;                                        % max-min dimension of the stick
            obj.microParamsPos(:,8)=energyp;                                       % energy at opening time
            
            obj.microParamsNeg(:,2)=obj.HistData1min(rn,2);
            obj.microParamsNeg(:,3)=obj.HistData1min(rn,3);
            obj.microParamsNeg(:,5)=volumen;                                       % volume at opening time
            obj.microParamsNeg(:,7)=stickn;                                        % max-min dimension of the stick
            obj.microParamsNeg(:,8)=energyn;                                       % energy at opening time
            
            plotMicroAnalysis(obj,nstep)
            
            
        end
        
        
        %%
        function obj=analysisMacroParams(obj,nstep)
            
            latency         = obj.inputResultsMatrix(:,10);
            minimumReturns  = obj.inputResultsMatrix(:,11);
            
            latencyp = latency(obj.rowRespOp);
            latencyn = latency(obj.rowResnOp);
            
            minimumReturnsp = minimumReturns(obj.rowRespOp);
            minimumReturnsn = minimumReturns(obj.rowResnOp);
            
            obj.macroParamsPos(:,1)= latencyp;                                    % latency of the positive operations
            obj.macroParamsPos(:,2)= minimumReturnsp;                             % minimum return touched by positive operations
            
            obj.macroParamsNeg(:,1)= latencyn;                                    % latency of the negative operations
            obj.macroParamsNeg(:,2)= minimumReturnsn;                             % minimum return touched by negative operations
            
            plotMacroAnalysis(obj,nstep)
            
        end
        
        
        %%
        function obj=analysisReturnsPattern(obj,nstepeq,dimCluster)
            
            % probability to have a wrong/correct operation at the time
            %   nstepeq after a given wrong/correct operation at time0
            
            colourp='-ob';
            [obj,xcounterp,~,counterPercp]=nstepeqProbability(obj,obj.rowRespOp,nstepeq);
            
            colourn='-or';
            [obj,xcountern,~,counterPercn]=nstepeqProbability(obj,obj.rowResnOp,nstepeq);
            
            figure
            title('Analysis of Returns Pattern');
            subplot(2,1,1)
            plot(xcounterp,counterPercp,colourp);
            xlabel('delay time (operation step)');
            ylabel('Probability -/+op (%)');
            hold on
            plot(xcountern,counterPercn,colourn);
            
            clear xcounterp counterPercp xcountern counterPercn
            
            % probability to have a cluster of wrong/correct operation of
            %   dimenstion dim
            
            [obj,xcounterp,~,counterPercp]=operationsClusterProbability(obj,obj.rowRespOp,dimCluster);
            
            [obj,xcountern,~,counterPercn]=operationsClusterProbability(obj,obj.rowResnOp,dimCluster);
            
            subplot(2,1,2)
            plot(xcounterp,counterPercp,colourp);
            xlabel('dimension of operations cluster');
            ylabel('Probability -/+op (%)');
            hold on
            plot(xcountern,counterPercn,colourn);
            
        end
        
        
        %%
        function obj=plotMicroAnalysis(obj,nstep)
            
            n=nstep;
            index=obj.rowHistOp;
            limitPerc=99.5;
            limitPercEn=95;
            
            volumes=obj.HistData1min(index,5);
            sticks=abs(obj.HistData1min(index,3)-obj.HistData1min(index,2));
            energies=(volumes).*(sticks./obj.freq).^2;
            
            
            figure
            title('Analysis of microscopic behaviour');
            
            % 1- VOLUME ANALYSIS: PDF as a function of absolute volume
            
            % prebinning for finding the upper limit of "limitPerc" % of operations
            nPDF=n*5;
            [xPDF,hPDF,~]=PDF(volumes,nPDF);
            [hCDF]=CDF(hPDF);
            [~,indexMax,~]=find(hCDF>=limitPerc);
            xMax=xPDF(indexMax(1));
            xMin=min(xPDF);
            
            subplot(3,2,1)
            [xPDFvol,hPDFvolp,hBinvolp]=PDF(obj.microParamsPos(:,5),n);
            [~,hPDFvoln,hBinvoln]=PDF(obj.microParamsNeg(:,5),n);
            plot(xPDFvol,hPDFvolp,'-b')
            hold on
            plot(xPDFvol,hPDFvoln,'-r')
            xlim([xMin xMax]);
            xlabel('volume');
            ylabel('PDF');
            
            % plot the % of positive operations as a function of absolute volume
            subplot(3,2,2)
            plot(xPDF,hCDF,'-k');
            hold on
            volDiffperc=(hBinvolp.*100)./(hBinvolp+hBinvoln);
            plot(xPDFvol,volDiffperc,'-r')
            axis([xMin xMax 0 100]);
            xlabel('volume');
            ylabel('+operation/total (%)');
            
            
            % 2- STICKs ANALYSIS: PDF as a function of absolute stick dimenstion
            
            % prebinning for finding the upper limit of "limitPerc" % of operations
            nPDF=n*5;
            [xPDF,hPDF,~]=PDF(sticks,nPDF);
            [hCDF]=CDF(hPDF);
            [~,indexMax,~]=find(hCDF>=limitPerc);
            xMax=xPDF(indexMax(1));
            xMin=min(xPDF);
            
            subplot(3,2,3)
            [xPDFvol,hPDFvolp,hBinvolp]=PDF(obj.microParamsPos(:,7),n);
            [~,hPDFvoln,hBinvoln]=PDF(obj.microParamsNeg(:,7),n);
            plot(xPDFvol,hPDFvolp,'-b')
            hold on
            plot(xPDFvol,hPDFvoln,'-r')
            xlim([xMin xMax]);
            xlabel('stick dimension');
            ylabel('PDF');
            
            % plot the % of positive operations as a function of stick dimension
            subplot(3,2,4)
            plot(xPDF,hCDF,'-k');
            hold on
            volDiffperc=(hBinvolp.*100)./(hBinvolp+hBinvoln);
            plot(xPDFvol,volDiffperc,'-r')
            axis([xMin xMax 0 100]);
            xlabel('stick dimension');
            ylabel('+operation/total (%)');
            
            
            % 3- ENERGY ANALYSIS: PDF as a function of puntual Cinetic Energy
            
            % prebinning for finding the upper limit of "limitPerc" % of operations
            nPDF=n*5000;
            [xPDF,hPDF,~]=PDF(energies,nPDF);
            [hCDF]=CDF(hPDF);
            [~,indexMax,~]=find(hCDF>=limitPercEn);
            xMax=xPDF(indexMax(1));
            
            subplot(3,2,5)
            [xPDFvol,hPDFvolp,hBinvolp]=PDF(obj.microParamsPos(:,8),n);
            [~,hPDFvoln,hBinvoln]=PDF(obj.microParamsNeg(:,8),n);
            plot(xPDFvol,hPDFvolp,'-b')
            hold on
            plot(xPDFvol,hPDFvoln,'-r')
            xlim([xMin xMax]);
            xlabel('energy');
            ylabel('PDF');
            
            % plot the % of positive operations as a function of energy
            subplot(3,2,6)
            plot(xPDF,hCDF,'-k');
            hold on
            volDiffperc=(hBinvolp.*100)./(hBinvolp+hBinvoln);
            plot(xPDFvol,volDiffperc,'-r')
            axis([xMin xMax 0 100]);
            xlabel('energy');
            ylabel('+operation/total (%)');
            
            
        end
        
        %%
        function obj=plotMacroAnalysis(obj,nstep)
            
            n=nstep;
            limitPerc=99.5;
     
            latencyp = obj.macroParamsPos(:,1);                                    
            latencyn = obj.macroParamsNeg(:,1); 
            
            minimumReturnsp = obj.macroParamsPos(:,2);        
            minimumReturnsn = obj.macroParamsNeg(:,2);             
            
            
            figure
            title('Analysis of operations Latency');
                        
            % 4- LATENCY ANALYSIS: PDF of operations latency
            
            % prebinning for finding the upper limit of "limitPerc" % of operations
            nPDF=n*5;
            [xPDF,hPDF,~]=PDF(latencyp,nPDF);
            [hCDF]=CDF(hPDF);
            [~,indexMax,~]=find(hCDF>=limitPerc);
            xMax=xPDF(indexMax(1));
            xMin=min(xPDF);
            
            returnsp = obj.win_operations (:,4);
            returnsn = obj.lost_operations (:,4);
            [~,xPDFlatp,~,hPDFlatp,hBinlatp,hBinIntegratedp,hPDFIntegratedp,~] = PDFcond(latencyp,returnsp,n);
            [~,xPDFlatn,~,hPDFlatn,hBinlatn,hBinIntegratedn,hPDFIntegratedn,~] = PDFcond(latencyn,returnsn,n);
            
            % PDF of the operations latency
            subplot(2,2,1)
            plot(xPDFlatp,hPDFlatp,'-b')
            hold on
            plot(xPDFlatn,hPDFlatn,'-r')
            xlim([xMin xMax]);
            xlabel('latency (mins)');
            ylabel('PDF');

            % plot the % of positive operations as a function of latency
            subplot(2,2,2)
            plot(xPDF,hCDF,'-k');
            hold on
            latDiffperc=(hBinlatp.*100)./(hBinlatp+hBinlatn);
            plot(xPDFlatp,latDiffperc,'-r')
            axis([xMin xMax 0 100]);
            xlabel('latency (mins)');
            ylabel('+operation/total (%)');
            
            % PDF of the operations latency weighed with returns
            subplot(2,2,3)
            plot(xPDFlatp,hPDFIntegratedp,'-b')
            hold on
            plot(xPDFlatn,hPDFIntegratedn,'-r')
            xlim([xMin xMax]);
            xlabel('latency (mins)');
            ylabel('PDF weighed with returns');
            
            % plot the % of positive operations as a function of latency weighed with returns
            subplot(2,2,4)
            plot(xPDF,hCDF,'-k');
            hold on
            latDiffperc=(hBinIntegratedp.*100)./(abs(hBinIntegratedn)+hBinIntegratedp);
            plot(xPDFlatp,latDiffperc,'-r')
            axis([xMin xMax 0 100]);
            xlabel('latency (mins)');
            ylabel('+operation/total (%) weighed with returns');           
            
            figure
            title('Analysis of pips earned distributed on Latency');
                        
            % 5- Analysis of pips earned distributed on Latency
            latDiffpips=hBinIntegratedn+hBinIntegratedp;
            plot(xPDFlatp,latDiffpips,'-r')
            hold on
            lin1=zeros(n);
            plot(xPDFlatp,lin1,'-c');
            yMin=min(latDiffpips);
            yMax=max(latDiffpips);
            axis([xMin xMax yMin-10 yMax+10]);
            xlabel('latency (mins)');
            ylabel('total returns (pips) distributed on latency');  
            
            
            
            figure
            title('Analysis of operations Minimum Returns');
                        
            % 6- Min RETURNS ANALYSIS: PDF of operations Min Returns

            % prebinning for finding the upper limit of "limitPerc" % of operations
            nPDF=n*5;
            [xPDF,hPDF,~]=PDF(minimumReturnsp,nPDF);
            [hCDF]=CDF(hPDF);
            [~,indexMax,~]=find(hCDF>=limitPerc);
            xMax=xPDF(indexMax(1));
            xMin=min(xPDF);
            
            % PDF of the operations Min Returns
            subplot(2,1,1)
            [xPDFmret,hPDFmretp,hBinmretp]=PDF(minimumReturnsp,n);
            [~,hPDFmretn,hBinmretn]=PDF(minimumReturnsn,n);
            plot(xPDFmret,hPDFmretp,'-b')
            hold on
            plot(xPDFmret,hPDFmretn,'-r')
            xlim([xMin xMax]);
            xlabel('min return touched (pips)');
            ylabel('PDF');
            
            % plot the % of positive operations as a function of Min Returns
            subplot(2,1,2)
            plot(xPDF,hCDF,'-k');
            hold on
            mretDiffperc=(hBinmretp.*100)./(hBinmretp+hBinmretn);
            plot(xPDFmret,mretDiffperc,'-r')
            axis([xMin xMax 0 100]);
            xlabel('min return touched (pips)');
            ylabel('+operation/total (%)');
            
            
        end
        
        %%
        function [obj,xcounter,counter,counterPerc]=nstepeqProbability(obj,r,nstepeq)
            
            % probability to have a wrong/correct operation at the time
            %   nstepeq after a given wrong/correct operation at time0
            
            n=nstepeq;
            l=length(r);
            counter=zeros(n-1,1);
            
            for i = 1 : l-n-1
                for j = 1 : n-1
                    distance=r(i+j)-r(i);
                    if distance <= n-1
                        counter(distance,1)=counter(distance,1)+1;
                    end
                end
            end
            
            xcounter=(1:n-1);
            counterPerc=(counter./(l-n-1)).*100;
            
        end
        
        
        %%
        function [obj,xcounter,counter,counterPerc]=operationsClusterProbability(obj,rowsOperation,dimCluster)
            
            % probability to have a cluster of wrong/correct operation of dimenstion dim
            
            n=dimCluster;
            l=length(rowsOperation);
            counter=zeros(n-1,1);
            
            for i = 1 : l-n-1
                for j = 1 : n-1
                    if rowsOperation(i+j) == rowsOperation(i)+j;
                        counter(j,1)=counter(j,1)+1;
                    end
                end
            end
            
            xcounter=(1+1:n);
            counterPerc=(counter./(l-n-1)).*100;
            
        end
        
        
        %%
        function obj=plotOperationOnHystorical(obj,timeSeriesPropertiesOffline)
            
            
            L=length(obj.HistData1min(:,4));
            xHistData1min=1:L;
            
            H  = timeSeriesPropertiesOffline.HurstExponent;
            Hd = timeSeriesPropertiesOffline.HurstDiff;
            Hs = timeSeriesPropertiesOffline.HurstSmooth;
            %             pV = TimeSeriesProperties.pValue(:);
            %             hL = TimeSeriesProperties.halflife(:);
            
            lnewTimeScale=length(H);
            start=(obj.nData+1)*obj.freq;
            stop=(lnewTimeScale+obj.nData)*obj.freq;
            xProperties=start:obj.freq:stop;
            
            figure
            s(1)=subplot(3,1,1);
            plot(xHistData1min,obj.HistData1min(:,4),'Color','k','LineWidth',1)
            
            hold on
            plot(obj.rowHistpOp,obj.HistData1min(obj.rowHistpOp,4),'ob')
            plot(obj.rowHistpCl,obj.HistData1min(obj.rowHistpCl,4),'*b')
            
            plot(obj.rowHistnOp,obj.HistData1min(obj.rowHistnOp,4),'or')
            plot(obj.rowHistnCl,obj.HistData1min(obj.rowHistnCl,4),'*r')
            
            windowSize1 = 10;
            a = (1/windowSize1)*ones(1,windowSize1);
            smoothClose1 = filter(a,1,obj.HistDatafreq(obj.nData+1:end,4));
            
            windowSize2 = 50;
            b = (1/windowSize2)*ones(1,windowSize2);
            smoothClose2 = filter(b,1,obj.HistDatafreq(obj.nData+1:end,4));
            
            line(xProperties(windowSize2:end),smoothClose1(windowSize2:end),'Color','b','LineWidth',1);
            line(xProperties(windowSize2:end),smoothClose2(windowSize2:end),'Color','r','LineWidth',1);
            
            legend('Price','Open win','Close win','Open lost','Close lost','MA10','MA60')
            
            
            s(2)=subplot(2,1,2);
            plot(xProperties,H,'-k');
            hold on
            lin1=zeros(length(xProperties));
            line(xProperties,lin1+0.5,'Color','r','LineWidth',1);
            
            smoothCoeff = 0.1;
            Hss = smooth(H,smoothCoeff,'rloess');
            line(xProperties,Hs,'Color','b','LineWidth',1);
            line(xProperties,Hss,'Color','g','LineWidth',1);
            
            legend('hurst exponent','random-walk line, H2 < 0.5 -> mean reverting -- H2 > 0.5 -> trending','hurst smooth','hurst smooth theoretical');
            
            s(3)=subplot(3,1,3);
            plot(xProperties,Hd,'b');
            line(xProperties,lin1,'Color','r','LineWidth',1);
            legend('first derivative', '0 line')
            
            linkaxes(s,'x');
            
            %             figure
            %             s2(1)=subplot(2,1,1);
            %             plot(xProperties,pV,'-k');
            %             hold on
            %             lin1=zeros(length(xProperties))+0.5;
            %             plot(xProperties,lin1,'-r');
            %             legend('pValue');
            %
            %             s2(1)=subplot(2,1,2);
            %             plot(xProperties,hL,'-k');
            %             legend('halfLife');
            %
            %             linkaxes(s2,'x');
            
            % plotyy(cumsum(obj.inputResultsMatrix(:,4)-obj.transCost),'plot');
        end
        
        
    end
    
end