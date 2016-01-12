%% load data


hisDataRaw=load('AUDCAD.csv');


actTimeScale = 1;
newTimeScale = 30;

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

% riscala temporalmente se richiesto
if newTimeScale > 1
    
    expert = TimeSeriesExpert_11;
    expert.rescaleData(hisData,actTimeScale,newTimeScale);
    
    closeXminsHisData = expert.closeVrescaled;
    
end

P = closeXminsHisData;


%% %%%%%%%%%%%%%%%%%%
%% generate signal macd

[macdvec, nineperma] = macd(P);
sMacd=macdvec-nineperma;
sMacd(sMacd>0)=1;
sMacd(sMacd<0)=-1;
esse=sMacd(2:end)+sMacd(1:end-1);
changeSignalMacd=find(esse==0);

%% plot signal macd

sMacdPos = find(sMacd==1);
sMacdNeg = find(sMacd==-1);

figure
plot(P,'LineWidth',1.5)
hold on
plot(sMacdPos,P(sMacdPos),'og','markersize',3,'LineWidth',2)
plot(sMacdNeg,P(sMacdNeg),'or','markersize',3,'LineWidth',2)

%% plot when macd changes signal

figure

plot(P,'LineWidth',2)
hold on
plot(changeSignalMacd,P(changeSignalMacd),'or','markersize',5,'LineWidth',2)


%% %%%%%%%%%%%%%%%%%%
%% generate signal Bollinger

% N = lookback period per calcolare media e stdev
N = 10;
% wApri = deviazione dallo zScore necessaria x aprire operaz
wApri = 2;

a = (1/N)*ones(1,N);
MA = filter(a,1,P);
MSTDEV = movingStd(P, N);

zScore=(P-MA)./MSTDEV;

sBoll = zeros(size(P));
% signals
sBoll(zScore < -wApri) = 1;
sBoll(zScore > wApri) = -1;

%%

sBollPos = find(sBoll==1);
sBollNeg = find(sBoll==-1);

figure
plot(P,'LineWidth',1.5)
hold on
plot(sBollPos,P(sBollPos),'og','markersize',3,'LineWidth',2)
plot(sBollNeg,P(sBollNeg),'or','markersize',3,'LineWidth',2)



%% plot macd and Boll with subplots

figure
ax(1) = subplot(2,1,1);
plot(P,'LineWidth',1.5)
hold on
plot(sMacdPos,P(sMacdPos),'og','markersize',3,'LineWidth',2)
plot(sMacdNeg,P(sMacdNeg),'or','markersize',3,'LineWidth',2)
legend('macd')
ax(2) = subplot(2,1,2);
plot(P,'LineWidth',1.5)
hold on
plot(sBollPos,P(sBollPos),'og','markersize',3,'LineWidth',2)
plot(sBollNeg,P(sBollNeg),'or','markersize',3,'LineWidth',2)
legend('Bollinger')
linkaxes(ax,'x')

%% %%%%%%%%%%%%%%%%%%
%% generate signal RSI

thresh = [30 70]; % default threshold for the RSI

% N = periodo(relativo all new time scale) su cui si basa l RSI
% M = M-period moving average
N = 10;
M = 5;

ma = movavg(P,M,M,'e');
ri = rsindex(P - ma, N);

indx    = ri < thresh(1);
indx    = [false; indx(1:end-1) & ~indx(2:end)];
sRSI(indx) = 1;
% Crossing the upper threshold
indx    = ri > thresh(2);
indx    = [false; indx(1:end-1) & ~indx(2:end)];
sRSI(indx) = -1;

%% plot signal RSI

sRSIPos = find(sRSI==1);
sRSINeg = find(sRSI==-1);

figure
plot(P,'LineWidth',1.5)
hold on
plot(sRSIPos,P(sRSIPos),'og','markersize',3,'LineWidth',2)
plot(sRSINeg,P(sRSINeg),'or','markersize',3,'LineWidth',2)