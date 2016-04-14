function [histData, newHistData] = load_historical_02(histName, actTimeScale, newTimeScale)

%%%%%%%%%%%%%%%%%%
% load a historical file and creates matrices of historical at the original and new time scales
% the output columns are (op,hi,lo,cl,vol,date)
% if the file does not contain date, will add a
% fake date column as the last (6th) column
% 
% IMPORTANT, please use:
% [HistData_1min,HistData_freq]=fromMT4HystToBktHistorical(actTimeScale,newTimeScale)
% for converting the dowloaded historical data from MT4 to the bkt historical
% standard!
%%%%%%%%%%%%%%%%%%

            hisDataRaw=load(histName);
            
            % remove lines with no data (holes)
            hisDataTemp = hisDataRaw( (hisDataRaw(:,1) ~=0), : );
            
            [r,c] = size(hisDataTemp);
            
            if c == 5
                
                histData(1,6) = datenum('01/01/2015 00:00', 'mm/dd/yyyy HH:MM');
                
                for j = 2:r;
                    
                    histData(j,6) = histData(1,6) + ( (actTimeScale/1440)*(j-1) );
                    
                end
                
            end

            % rescale data if requested
            if newTimeScale > 1
                
                expert = TimeSeriesExpert_11;
                
                expert.rescaleData(histData,actTimeScale,newTimeScale);
                
                newHistData(:,1) = expert.openVrescaled;
                newHistData(:,2) = expert.maxVrescaled;
                newHistData(:,3) = expert.minVrescaled;
                newHistData(:,4) = expert.closeVrescaled;
                newHistData(:,5) = expert.volrescaled;
                newHistData(:,6) = expert.openDrescaled;
             
            else
                newHistData = histData;
            end
            
end



