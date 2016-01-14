function visualize_signals(historical,timescale,signal,params)

% signal:
% 'macd' : moving average convergence divergence
% 'rsi': relative strength index
% 'bollinger': bollinger bands
%
%
%
%
%
%




% load data
hisDataRaw=load(historical);

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
    hisData(j,6) = hisData(1,6) + ( (1/1440)*(j-1) );
end

% riscala temporalmente se richiesto
if timescale > 1
    
    expert = TimeSeriesExpert_11;
    expert.rescaleData(hisData,1,timescale);
    
    op = expert.openVrescaled;
    hi = expert.maxVrescaled;
    lo = expert.minVrescaled;
    cl = expert.closeVrescaled;
    vol = expert.volrescaled;
    dates = expert.openDrescaled;
    
    clearvars expert;
    
else
    
    op = hisData(:,1);
    hi = hisData(:,2);
    lo = hisData(:,3);
    cl = hisData(:,4);
    vol = hisData(:,5);
    dates = hisData(:,6);
    
end

clearvars hisData hisDataTemp hisDataRaw;


switch lower(signal)
    
    case 'macd'
        
        [macdvec, nineperma] = macd(cl);
        sMacd=macdvec-nineperma;
        sMacd(sMacd>0)=1;
        sMacd(sMacd<0)=-1;
        esse=sMacd(2:end)+sMacd(1:end-1);
        changeSignalMacd=find(esse==0);
        
        sMacdPos = find(sMacd==1);
        sMacdNeg = find(sMacd==-1);
        
        % plot macd signal
        figure
        plot(cl,'LineWidth',1.5)
        hold on
        plot(sMacdPos,cl(sMacdPos),'og','markersize',3,'LineWidth',2)
        plot(sMacdNeg,cl(sMacdNeg),'or','markersize',3,'LineWidth',2)
        title('macd')
        
        % plot when macd changes signal
        figure
        plot(cl,'LineWidth',2)
        hold on
        plot(changeSignalMacd,cl(changeSignalMacd),'or','markersize',5,'LineWidth',2)
        title('when macd changes signal')
        
        
    case 'rsi'
        
        thresh = [30 70]; % default threshold for the RSI
        
        % N = periodo(relativo all new time scale) su cui si basa l RSI
        % M = M-period moving average
        if isempty(params)
            N = 10;
            M = 5;
        else
            N = params{1};
            M = params{2};
        end
        
        ma = movavg(cl,M,M,'e');
        ri = rsindex(cl - ma, N);
        
        indx    = ri < thresh(1);
        indx    = [false; indx(1:end-1) & ~indx(2:end)];
        sRSI(indx) = 1;
        % Crossing the upper threshold
        indx    = ri > thresh(2);
        indx    = [false; indx(1:end-1) & ~indx(2:end)];
        sRSI(indx) = -1;
        
        % plot signal RSI
        
        sRSIPos = find(sRSI==1);
        sRSINeg = find(sRSI==-1);
        
        figure
        plot(cl,'LineWidth',1.5)
        hold on
        plot(sRSIPos,cl(sRSIPos),'og','markersize',3,'LineWidth',2)
        plot(sRSINeg,cl(sRSINeg),'or','markersize',3,'LineWidth',2)
        
    case 'bollinger' %DA FINIRE!!!
        
        % N = lookback period
        % std = standard dev per la banda
        if isempty(params)
            N = 10;
            weight = 1;
            std = 2;
        else
            N = params{1};
            weight = params{2};
            std = params{3};
        end
        
%         a = (1/N)*ones(1,N);
%         MA = filter(a,1,cl);
%         MSTDEV = movingStd(cl, N);
%         
%         zScore=(cl-MA)./MSTDEV;
%         
%         sBoll = zeros(size(cl));
%         % signals
%         sBoll(zScore < -std) = 1;
%         sBoll(zScore > std) = -1;
%         
        outbol = tech_indicators(cl ,'boll' ,N,weight,std);
        middl = outbol(:,1);
        upp = outbol(:,2);
        lowe = outbol(:,3);
        
        % plot Bollinger bands
        figure
        plot(cl,'LineWidth',2)
        hold on
        plot(middl,'-g')
        plot(upp,'r')
        plot(lowe,'r')
        title('Bollinger Bands')
        
end