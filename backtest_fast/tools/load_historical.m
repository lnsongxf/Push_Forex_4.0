function [hisData, newHisData] = load_historical(histName, actTimeScale, newTimeScale)

%%%%%%%%%%%%%%%%%%
% load a historical file and creates matrices of historical at the original and new time scales
% the output columns are (op,hi,lo,cl,vol,date)
% if the file has dates in the first column, will delete them and add a
% fake date column as the last (6th) column
%
%%%%%%%%%%%%%%%%%%


            hisDataRaw=load(histName);
            
            % remove lines with no data (holes)
            hisDataTemp = hisDataRaw( (hisDataRaw(:,1) ~=0), : );
            
            [r,c] = size(hisDataTemp);
            
            %remove badly loaded dates (will add fake dates in a sec)
            if c ~= 5
                hisData = hisDataTemp(:,c-4:c);
            else
                hisData = hisDataTemp;
            end
            
            hisData(1,6) = datenum('01/01/2015 00:00', 'mm/dd/yyyy HH:MM');
            
            for j = 2:r;
                hisData(j,6) = hisData(1,6) + ( (actTimeScale/1440)*(j-1) );
            end
            
            
            % rescale data if requested
            if newTimeScale > 1
                
                expert = TimeSeriesExpert_11;
                
                expert.rescaleData(hisData,actTimeScale,newTimeScale);
                
                newHisData(:,1) = expert.openVrescaled;
                newHisData(:,2) = expert.maxVrescaled;
                newHisData(:,3) = expert.minVrescaled;
                newHisData(:,4) = expert.closeVrescaled;
                newHisData(:,5) = expert.volrescaled;
                newHisData(:,6) = expert.openDrescaled;
             
            else
                newHisData = hisData;
            end
            
end