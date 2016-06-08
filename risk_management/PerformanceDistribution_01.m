classdef PerformanceDistribution < handle
    
    properties
        nameAlgo;
        origin;
        cross;
        freq;
        transCost;
        inputResultsMatrix
        HistData1min
        HistDatafreq
        
        microParamsPos
        microParamsNeg
    end
    
    methods
        
        %%
        
        function obj=calcPerformanceDistr(obj,nameAlgo_,origin_,cross_,freq_,transCost_,inputResultsMatrix_,HistData_1min_,HistData_freq_)
            
            %
            % example of the use:
            % After having created the object with the name: 'objname'
            % objname=objname.calcPerformanceDistr('real_17','bktWeb','EURUSD',5,1,outputBktWeb,history_1min,history_5min)
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
            obj=obj.analysisMacroParams;
            obj=obj.analysisMicroParams;
            obj=obj.analysisReturnsPattern;
            
        end
        
        
        
        %%
        function obj=analysisMacroParams(obj)
            
            
            
            
            
            
        end
        
        %%
        function obj=analysisMicroParams(obj)
            
            
            s=size(obj.inputResultsMatrix);
            %obj.microParamsPos=zeros(s(1),6);
            %obj.microParamsNeg=zeros(s(1),6);
            
            j=0;
            k=0;
            
            for i = 1:s(1)
                %display(i)
                date=obj.inputResultsMatrix(i,7);
                [row,~,~] = find(obj.HistData1min(:,6)==date);
                
                if obj.inputResultsMatrix(i,4)>0
                    j=j+1;
                    obj.microParamsPos(j,1)=obj.HistData1min(row,1);
                    obj.microParamsPos(j,2)=obj.HistData1min(row,2);
                    obj.microParamsPos(j,3)=obj.HistData1min(row,3);
                    obj.microParamsPos(j,4)=obj.HistData1min(row,4);
                    obj.microParamsPos(j,5)=obj.HistData1min(row,5);
                    obj.microParamsPos(j,6)=obj.HistData1min(row,6);
                else
                    k=k+1;
                    obj.microParamsNeg(k,1)=obj.HistData1min(row,1);
                    obj.microParamsNeg(k,2)=obj.HistData1min(row,2);
                    obj.microParamsNeg(k,3)=obj.HistData1min(row,3);
                    obj.microParamsNeg(k,4)=obj.HistData1min(row,4);
                    obj.microParamsNeg(k,5)=obj.HistData1min(row,5);
                    obj.microParamsNeg(k,6)=obj.HistData1min(row,6);
                end
                
            end
            
                       
            
            figure(1)
            
            np=20;
            nn=10;
            
%             subplot(2,1,1)
            hp=hist(obj.microParamsPos(:,5),np);
            minVp=min(obj.microParamsPos(:,5));
            maxVp=max(obj.microParamsPos(:,5));
            xhp=minVp:(maxVp-minVp)/(np-1):maxVp;
            areap=trapz(xhp,hp);
            hpn=hp./areap;
            %plot(xhp,hpn,'-ob')
            semilogy(xhp,hpn,'-ob')
            hold on
                       
            hn=hist(obj.microParamsNeg(:,5),nn);
            minVn=min(obj.microParamsNeg(:,5));
            maxVn=max(obj.microParamsNeg(:,5));
            xhn=minVn:(maxVn-minVn)/(nn-1):maxVn;
            arean=trapz(xhn,hn);
            hnn=hn./arean;
            %plot(xhn,hnn,'-or')
            semilogy(xhn,hnn,'-or')
            areatn=trapz(xhn,hnn);
            display(areatn);
            areatp=trapz(xhp,hpn);
            display(areatp);
            
            toc
            
%             subplot(2,1,2)
%             hp=hist(obj.microParamsPos(:,5),np);
%             minVp=min(obj.microParamsPos(:,5));
%             maxVp=max(obj.microParamsPos(:,5));
%             xhp=minVp:(maxVp-minVp)/(np-1):maxVp;
%             plot(xhp,hp,'-ob')
%             hold on
%             
%             hn=hist(obj.microParamsNeg(:,5),nn);
%             minVn=min(obj.microParamsNeg(:,5));
%             maxVn=max(obj.microParamsNeg(:,5));
%             xhn=minVn:(maxVn-minVn)/(nn-1):maxVn;
%             plot(xhn,hn,'-or')           
            
            
        end
        
        %%
        function obj=analysisReturnsPattern(obj)
            
            
            
            
            
        end
        
    end
    
end