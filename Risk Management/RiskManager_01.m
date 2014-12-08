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
            
            exReturns1day=performance.ferialExReturns;
%             totalFerialDays=252;
%             totalmonths=12;
            ferialDaysPerMonth=2;  %test (21)
            
            l=length(exReturns1day);
            n=floor(l/ferialDaysPerMonth);
            exReturns21days=zeros(n,1);
            j=0;
            for i = 1:n
                exReturns21days(j+1)=sum(exReturns1day(ferialDaysPerMonth*j+1:ferialDaysPerMonth*(j+1)));
                j=j+1;
            end
                        
            nPDF1day=6;
            [xPDF1day,hPDF1day,~]=PDF(exReturns1day,min(exReturns1day),max(exReturns1day),nPDF1day);
            [hCDF1day]=CDF(hPDF1day);
            
            nPDF21days=4;
            [xPDF21days,hPDF21days,~]=PDF(exReturns21days,min(exReturns21days),max(exReturns21days),nPDF21days);
            [hCDF21days]=CDF(hPDF21days);
            
            figure
            subplot(2,1,1)
            [ax,p1,p2] = plotyy(xPDF1day,hPDF1day,xPDF1day,hCDF1day,'plot');
            set(p1,'LineStyle','-','LineWidth',1,'Marker','o','Color','r')
            set(ax(1),'YColor','k')
            set(p2,'LineStyle','--','LineWidth',2,'Color','k')
            set(ax(2),'YColor','k')
            grid on
            ylabel(ax(1),'Probability Density Function','Color','k') % label left y-axis
            ylabel(ax(2),'Cumulative Density Function','Color','k') % label right y-axis
            xlabel(ax(2),'Returns (pips)','Color','k') % label x-axis
            title('VaR evaluation');
            
            subplot(2,1,2)
            [ax,p1,p2] = plotyy(xPDF21days,hPDF21days,xPDF21days,hCDF21days,'plot');
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
