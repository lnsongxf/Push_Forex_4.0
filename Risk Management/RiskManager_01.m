classdef RiskManager_01 < handle
    
    properties
        
        nameAlgo;
        origin;
        period;
        cross;
        freq;
        transCost;
        inputResultsMatrix;
        
    end
    
    
    methods
        %% VaR calculation
        
        function obj=VaR(obj,performance,nPDF1day,nPDF21days)
            
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
            % nstepeq               ... distance between a given wrong/correct operation and the next
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
            
            % 1- intraday VaR, timeframe = 1 day
            exReturns1day=performance.ferialExReturns;
            nPDF1day=6;
            [xPDF1day,hPDF1day,~]=PDF(exReturns1day,min(exReturns1day),max(exReturns1day),nPDF1day);
            [hCDF1day]=CDF(hPDF1day);
            
            figure
            subplot(2,1,1)
            [ax,p1,p2] = plotyy(xPDF1day,hPDF1day,xPDF1day,hCDF1day,'plot');
            set(p1,'LineStyle','-','LineWidth',1,'Marker','o','Color','r')
            set(ax(1),'YColor','k')
            set(p2,'LineStyle','--','LineWidth',2,'Color','k')
            set(ax(2),'YColor','k')
            grid on
            ylabel(ax(1),'Probability Density Function','Color','k')                            % label left y-axis
            ylabel(ax(2),'Cumulative Density Function','Color','k')                             % label right y-axis
            xlabel(ax(2),'Returns per day (pips)','Color','k')                                  % label x-axis
            title('VaR, timeframe = 1 day');
            
            % 2- monthly VaR, timeframe = 21 days
            ferialDaysPerMonth=1;                                                               % total number of ferial days in a year = 252;
            
            l=length(exReturns1day);
            month=floor(l/ferialDaysPerMonth);
            if month<1
                h=msgbox('not enough data to evaluate monthly VaR','WARN','warn');
                waitfor(h)
                return
            else
                n=floor(l/ferialDaysPerMonth);
                exReturns21days=zeros(n,1);
                j=0;
                for i = 1:n
                    exReturns21days(j+1)=sum(exReturns1day(ferialDaysPerMonth*j+1:ferialDaysPerMonth*(j+1)));
                    j=j+1;
                end
                nPDF21days=6;
                [xPDF21days,hPDF21days,~]=PDF(exReturns21days,min(exReturns21days),max(exReturns21days),nPDF21days);
                [hCDF21days]=CDF(hPDF21days);
                
                subplot(2,1,2)
                [ax,p1,p2] = plotyy(xPDF21days,hPDF21days,xPDF21days,hCDF21days,'plot');
                set(p1,'LineStyle','-','LineWidth',1,'Marker','o','Color','r')
                set(ax(1),'YColor','k')
                set(p2,'LineStyle','--','LineWidth',2,'Color','k')
                set(ax(2),'YColor','k')
                grid on
                ylabel(ax(1),'Probability Density Function','Color','k')                        % label left y-axis
                ylabel(ax(2),'Cumulative Density Function','Color','k')                         % label right y-axis
                xlabel(ax(2),'Returns per month (pips)','Color','k')                            % label x-axis
                title('VaR, timeframe = 1 month');
            end
            
            
            
        end
        
        
    end
    
end
