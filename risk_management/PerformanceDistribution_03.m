classdef PerformanceDistribution_03 < handle
    
    properties
        nameAlgo;
        origin;
        cross;
        freq;
        transCost;
        inputResultsMatrix
        HistData1min
        HistDatafreq
        
        rowHist
        rowHistp
        rowHistn
        rowResp
        rowResn
        microParamsPos
        microParamsNeg
    end
    
    methods
        
        %%
        
        function obj=calcPerformanceDistr(obj,nameAlgo_,origin_,cross_,freq_,transCost_,inputResultsMatrix_,HistData_1min_,HistData_freq_,nstep,nstepeq,dimCluster,plotPerDistribution)
            
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
            % pd=PerformanceDistribution_03;
            % pd=pd.calcPerformanceDistr('real_17','bktWeb','EURUSD',5,1,bkt_Algo002.outputBktOffline,bkt_Algo002.starthisData,bkt_Algo002.newHisData,12,10,10,5)
            %
            
            
            tic
            
            matrix = find(inputResultsMatrix_(:,6));
            obj.inputResultsMatrix=inputResultsMatrix_(matrix,:);
            
            
            obj.nameAlgo=nameAlgo_;
            obj.origin=origin_;
            obj.cross=cross_;
            obj.freq=freq_;
            obj.transCost=transCost_;
            obj.HistData1min=HistData_1min_;
            obj.HistDatafreq=HistData_freq_;
            
            % display(obj.HistData1min(1:10,:));
            
            s=size(obj.inputResultsMatrix);
            obj.rowHist=zeros(s(1),1);                                      % index of anykind of operations
            rp=zeros(s(1),1);                                               % index of positive operations in the historical
            rn=zeros(s(1),1);                                               % index of negative operations in the historical
            resp=zeros(s(1),1);                                             % index of positive operations in the results matrix
            resn=zeros(s(1),1);                                             % index of positive operations in the results matrix
            
            j=0;
            k=0;
            
            for i = 1:s(1)
                date=obj.inputResultsMatrix(i,7);
                % datestr(date, 'mm/dd/yyyy HH:MM')
                
                [obj.rowHist(i),~,~] = find(obj.HistData1min(:,6)==date);
                
                if obj.inputResultsMatrix(i,4)>0
                    j=j+1;
                    rp(j)=obj.rowHist(i);
                    resp(j)=i;
                else
                    k=k+1;
                    rn(k)=obj.rowHist(i);
                    resn(k)=i;
                end
            end
            
            ip=rp>0;
            in=rn>0;
            obj.rowHistp=rp(ip);
            obj.rowHistn=rn(in);
            iresp=resp>0;
            iresn=resn>0;
            obj.rowResp=resp(iresp);
            obj.rowResn=resn(iresn);
            
            switch plotPerDistribution
                case 0
                    
                case 1
                    obj=obj.analysisMicroParams(nstep);
                case 2
                    obj=obj.analysisMacroParams;
                case 3
                    obj=obj.analysisReturnsPattern(nstepeq,dimCluster);
                case 4
                    obj=obj.plotOperationOnHystorical;
                case 5
                    obj=obj.analysisMicroParams(nstep);
                    obj=obj.analysisMacroParams;
                    obj=obj.analysisReturnsPattern(nstepeq,dimCluster);
                    obj=obj.plotOperationOnHystorical;
            end
            
            toc
            
        end
        
        
        
        %%
        function obj=analysisMacroParams(obj)
            
            
        end
        
        %%
        function obj=analysisMicroParams(obj,nstep)
            
            rp=obj.rowHistp;
            rn=obj.rowHistn;
            
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
        function obj=analysisReturnsPattern(obj,nstepeq,dimCluster)
            
            % probability to have a wrong/correct operation at the time
            %   nstepeq after a given wrong/correct operation at time0
            
            colourp='-ob';
            [obj,xcounterp,~,counterPercp]=nstepeqProbability(obj,obj.rowResp,nstepeq);
            
            colourn='-or';
            [obj,xcountern,~,counterPercn]=nstepeqProbability(obj,obj.rowResn,nstepeq);
            
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
            
            [obj,xcounterp,~,counterPercp]=operationsClusterProbability(obj,obj.rowResp,dimCluster);
            
            [obj,xcountern,~,counterPercn]=operationsClusterProbability(obj,obj.rowResn,dimCluster);
            
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
            index=obj.rowHist;
            limitPerc=99.5;
            limitPercEn=95;
            
            volumes=obj.HistData1min(index,5);
            sticks=abs(obj.HistData1min(index,3)-obj.HistData1min(index,2));
            energies=(0.5.*volumes).*(sticks./obj.freq).^2;
            
            
            figure
            title('Analysis of microscopic behaviour');
            
            % 1- VOLUME ANALYSIS: PDF as a function of absolute volume
            
            % prebinning for finding the upper limit of "limitPerc" % of operations
            nPDF=n*5;
            [xPDF,hPDF,~]=PDF(volumes,min(volumes),max(volumes),nPDF);
            [hCDF]=CDF(hPDF);
            [~,indexMax,~]=find(hCDF>=limitPerc);
            xMax=xPDF(indexMax(1));
            
            subplot(3,2,1)
            [xPDFvol,hPDFvolp,hBinvolp]=PDF(obj.microParamsPos(:,5),0,xMax,n);
            [~,hPDFvoln,hBinvoln]=PDF(obj.microParamsNeg(:,5),0,xMax,n);
            plot(xPDFvol,hPDFvolp,'-b')
            hold on
            plot(xPDFvol,hPDFvoln,'-r')
            xlabel('volume');
            ylabel('PDF');
            
            % plot the % of positive operations as a function of absolute volume
            subplot(3,2,2)
            plot(xPDF,hCDF,'-k');
            hold on
            volDiffperc=(hBinvolp.*100)./(hBinvolp+hBinvoln);
            plot(xPDFvol,volDiffperc,'-r')
            axis([0 xMax 0 100]);
            xlabel('volume');
            ylabel('+operation/total (%)');
            
            
            % 2- STICKs ANALYSIS: PDF as a function of absolute stick dimenstion
            
            % prebinning for finding the upper limit of "limitPerc" % of operations
            nPDF=n*5;
            [xPDF,hPDF,~]=PDF(sticks,min(sticks),max(sticks),nPDF);
            [hCDF]=CDF(hPDF);
            [~,indexMax,~]=find(hCDF>=limitPerc);
            xMax=xPDF(indexMax(1));
            xMin=min(xPDF);
            
            subplot(3,2,3)
            [xPDFvol,hPDFvolp,hBinvolp]=PDF(obj.microParamsPos(:,7),xMin,xMax,n);
            [~,hPDFvoln,hBinvoln]=PDF(obj.microParamsNeg(:,7),xMin,xMax,n);
            plot(xPDFvol,hPDFvolp,'-b')
            hold on
            plot(xPDFvol,hPDFvoln,'-r')
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
            [xPDF,hPDF,~]=PDF(energies,min(energies),max(energies),nPDF);
            [hCDF]=CDF(hPDF);
            [~,indexMax,~]=find(hCDF>=limitPercEn);
            xMax=xPDF(indexMax(1));
            
            subplot(3,2,5)
            [xPDFvol,hPDFvolp,hBinvolp]=PDF(obj.microParamsPos(:,8),0,xMax,n);
            [~,hPDFvoln,hBinvoln]=PDF(obj.microParamsNeg(:,8),0,xMax,n);
            plot(xPDFvol,hPDFvolp,'-b')
            hold on
            plot(xPDFvol,hPDFvoln,'-r')
            xlabel('energy');
            ylabel('PDF');
            
            % plot the % of positive operations as a function of energy
            subplot(3,2,6)
            plot(xPDF,hCDF,'-k');
            hold on
            volDiffperc=(hBinvolp.*100)./(hBinvolp+hBinvoln);
            plot(xPDFvol,volDiffperc,'-r')
            axis([0 xMax 0 100]);
            xlabel('energy');
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
        function obj=plotOperationOnHystorical(obj)
            
            [rowHistfreqOpenp,rowHistfreqClosep]=rowPositionOnHystorical(obj.HistDatafreq,obj.inputResultsMatrix(obj.rowResp,:));
            [rowHistfreqOpenn,rowHistfreqClosen]=rowPositionOnHystorical(obj.HistDatafreq,obj.inputResultsMatrix(obj.rowResn,:));
            
            figure
            start=min(rowHistfreqOpenp(1),rowHistfreqOpenn(1));
            stop=max(rowHistfreqClosep(end),rowHistfreqClosen(end));
            rowHistDatafreq=start:stop;
            operHistDatafreq=obj.HistDatafreq(start:stop,1);
            
            plot(rowHistDatafreq,operHistDatafreq,'-k','LineWidth',1)
            hold on
            plot(rowHistfreqOpenp,obj.inputResultsMatrix(obj.rowResp,2),'ob')
            plot(rowHistfreqClosep,obj.inputResultsMatrix(obj.rowResp,3),'*b')
            plot(rowHistfreqOpenn,obj.inputResultsMatrix(obj.rowResn,2),'or')
            plot(rowHistfreqClosen,obj.inputResultsMatrix(obj.rowResn,3),'*r')
            legend('Price','openP win','closeP win','openP lost','closeP lost')
            % plotyy(cumsum(obj.inputResultsMatrix(:,4)-obj.transCost),'plot');
        end
        
        
    end
    
end