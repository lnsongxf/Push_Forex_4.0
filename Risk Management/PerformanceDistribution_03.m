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
        
        function obj=calcPerformanceDistr(obj,nameAlgo_,origin_,cross_,freq_,transCost_,inputResultsMatrix_,HistData_1min_,HistData_freq_,nstep,nstepeq,dimCluster)
            
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
            % HistData_freq_        ... 5mins-hystorical data correspondet to the period of test
            % nstep                 ... number of binnig steps
            % nstepeq               ... distance between a given worng/correct operation and the next
            % dimCluster            ... number of wrong/correct subsequent operations (dimension of cluster)
            %
            % OUTPUT parameters:
            % -------------------------------------------------------------
            %
            %
            %
            % EXAMPLE of use:
            % -------------------------------------------------------------
            % objname=PerformanceDistribution_03;
            % objname=objname.calcPerformanceDistr('real_17','bktWeb','EURUSD',5,1,outputBktWeb,history_1min,history_5min,12,10,10);
            %
            
            
            tic
            if strcmp(origin_,'bktWeb')
                dim=size(inputResultsMatrix_);
                real=inputResultsMatrix_(:,6);
                nRows=sum(real(:));
                oneMatrix=zeros(dim(1),dim(2));
                for i = 1: dim(2)
                    oneMatrix(:,i)=real;
                end
                [~,~,matrix] = find(inputResultsMatrix_.*oneMatrix);
                obj.inputResultsMatrix=reshape(matrix,nRows,dim(2));
            elseif strcmp(origin_,'demo')
                dim=size(inputResultsMatrix_);
                real=inputResultsMatrix_(:,6);
                nRows=sum(real(:));
                oneMatrix=zeros(dim(1),dim(2));
                for i = 1: dim(2)
                    oneMatrix(:,i)=real;
                end
                [~,~,matrix] = find(inputResultsMatrix_.*oneMatrix);
                obj.inputResultsMatrix=reshape(matrix,nRows,dim(2));
            elseif strcmp(origin_,'bkt')
                dim=size(inputResultsMatrix_);
                real=inputResultsMatrix_(:,6);
                nRows=sum(real(:));
                oneMatrix=zeros(dim(1),dim(2));
                for i = 1: dim(2)
                    oneMatrix(:,i)=real;
                end
                [~,~,matrix] = find(inputResultsMatrix_.*oneMatrix);
                obj.inputResultsMatrix=reshape(matrix,nRows,dim(2));
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
            obj.HistData1min=HistData_1min_;
            obj.HistDatafreq=HistData_freq_;
            
            
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
            
            
            obj=obj.analysisMacroParams;
            obj=obj.analysisMicroParams(nstep);
            obj=obj.analysisReturnsPattern(nstepeq,dimCluster);
            obj=obj.plotOperationOnHystorical;
            
            
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
            stickp=obj.HistData1min(rp,3)-obj.HistData1min(rp,2);
            stickn=obj.HistData1min(rn,3)-obj.HistData1min(rn,2);
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
            [obj,xcounterp,counterp,counterPercp]=nstepeqProbability(obj,obj.rowResp,nstepeq);
            
            colourn='-or';
            [obj,xcountern,countern,counterPercn]=nstepeqProbability(obj,obj.rowResn,nstepeq);
            
            figure
            title('Analysis of Returns Pattern');
            subplot(2,1,1)
            plot(xcounterp,counterPercp,colourp);
            xlabel('tn (operation step)');
            ylabel('Probability -/+op (%)');
            hold on
            plot(xcountern,counterPercn,colourn);
            
            clear xcounterp counterp counterPercp xcountern countern counterPercn
            
            % probability to have a cluster of wrong/correct operation of
            %   dimenstion dim
            
            [obj,xcounterp,counterp,counterPercp]=operationsClusterProbability(obj,obj.rowResp,dimCluster);
            
            [obj,xcountern,countern,counterPercn]=operationsClusterProbability(obj,obj.rowResn,dimCluster);
            
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
            sticks=obj.HistData1min(index,3)-obj.HistData1min(index,2);
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
            plot(xPDFvol,hPDFvolp,'-ob')
            hold on
            plot(xPDFvol,hPDFvoln,'-or')
            xlabel('volume');
            ylabel('PDF');
            
            % plot the % of positive operations as a function of absolute volume
            subplot(3,2,2)
            plot(xPDF,hCDF,'-ok');
            hold on
            volDiffperc=(hBinvolp.*100)./(hBinvolp+hBinvoln);
            plot(xPDFvol,volDiffperc,'-or')
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
            
            subplot(3,2,3)
            [xPDFvol,hPDFvolp,hBinvolp]=PDF(obj.microParamsPos(:,7),0,xMax,n);
            [~,hPDFvoln,hBinvoln]=PDF(obj.microParamsNeg(:,7),0,xMax,n);
            plot(xPDFvol,hPDFvolp,'-ob')
            hold on
            plot(xPDFvol,hPDFvoln,'-or')
            xlabel('stick dimension');
            ylabel('PDF');
            
            % plot the % of positive operations as a function of stick dimension
            subplot(3,2,4)
            plot(xPDF,hCDF,'-ok');
            hold on
            volDiffperc=(hBinvolp.*100)./(hBinvolp+hBinvoln);
            plot(xPDFvol,volDiffperc,'-or')
            axis([0 xMax 0 100]);
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
            plot(xPDFvol,hPDFvolp,'-ob')
            hold on
            plot(xPDFvol,hPDFvoln,'-or')
            xlabel('energy');
            ylabel('PDF');
            
            % plot the % of positive operations as a function of energy
            subplot(3,2,6)
            plot(xPDF,hCDF,'-k');
            hold on
            volDiffperc=(hBinvolp.*100)./(hBinvolp+hBinvoln);
            plot(xPDFvol,volDiffperc,'-or')
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
            plot(obj.HistDatafreq(:,1),'-k')
            hold on
            plot(rowHistfreqOpenp,obj.inputResultsMatrix(obj.rowResp,2),'ob')
            plot(rowHistfreqClosep,obj.inputResultsMatrix(obj.rowResp,3),'*b')
            plot(rowHistfreqOpenn,obj.inputResultsMatrix(obj.rowResn,2),'or')
            plot(rowHistfreqClosen,obj.inputResultsMatrix(obj.rowResn,3),'*r')
                        
        end
        
        
    end
    
end