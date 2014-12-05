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
        
        function obj=VaR(obj,performance)
            
            timeframe1day=performance.ferialExReturns;

            nPDF=6;
            [xPDF,hPDF,~]=PDF(timeframe1day,min(timeframe1day),max(timeframe1day),nPDF);
            [hCDF]=CDF(hPDF);
            
            figure
            [ax,p1,p2] = plotyy(xPDF,hPDF,xPDF,hCDF,'plot');
            set(p1,'LineStyle','-','LineWidth',1,'Marker','o','Color','r')
            set(ax(1),'YColor','k')
            set(p2,'LineStyle','--','LineWidth',2,'Color','k')
            set(ax(2),'YColor','k')
            grid on
            ylabel(ax(1),'Probability Density Function','Color','k') % label left y-axis
            ylabel(ax(2),'Cumulative Density Function','Color','k') % label right y-axis
            xlabel(ax(2),'Returns (pips)','Color','k') % label x-axis
            title('VaR evaluation');
            
        end
        
        
    end
    
end
