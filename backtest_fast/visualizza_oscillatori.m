
%%%%%%%%%%

historical= 'EURUSD_2012_2015.csv';
timescale = 30;
kperiods1 = 5;
kperiods2 = 10;
kperiods3 = 20;

%%%%%%%%%


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

stosc1 = stochosc(hi, lo, cl, kperiods1, 1);
FpK1 = stosc1(:,1);

s_oversold1 = zeros(size(FpK1));
s_overbought1 = zeros(size(FpK1));
s_oversold1(FpK1<20) = 1;
s_overbought1(FpK1>80) = -1;

diff_long1 = [ 0 ; diff(s_oversold1) ];
signal_long1 = find(diff_long1==-1); % quando passa da 1 a 0 (diff = -1)

diff_short1 = [ 0 ; diff(s_overbought1) ];
signal_short1 = find(diff_short1==1); % quando passa da -1 a 0 (diff = 1)


stosc2 = stochosc(hi, lo, cl, kperiods2, 1);
FpK2 = stosc2(:,1);

s_oversold2 = zeros(size(FpK2));
s_overbought2 = zeros(size(FpK2));
s_oversold2(FpK2<20) = 1;
s_overbought2(FpK2>80) = -1;

diff_long2 = [ 0 ; diff(s_oversold2) ];
signal_long2 = find(diff_long2==-1); % quando passa da 1 a 0 (diff = -1)

diff_short2 = [ 0 ; diff(s_overbought2) ];
signal_short2 = find(diff_short2==1); % quando passa da -1 a 0 (diff = 1)


stosc3 = stochosc(hi, lo, cl, kperiods3, 1);
FpK3 = stosc3(:,1);

s_oversold3 = zeros(size(FpK3));
s_overbought3 = zeros(size(FpK3));
s_oversold3(FpK3<20) = 1;
s_overbought3(FpK3>80) = -1;

diff_long3 = [ 0 ; diff(s_oversold3) ];
signal_long3 = find(diff_long3==-1); % quando passa da 1 a 0 (diff = -1)

diff_short3 = [ 0 ; diff(s_overbought3) ];
signal_short3 = find(diff_short3==1); % quando passa da -1 a 0 (diff = 1)

final_signal_long = intersect(intersect(signal_long3,signal_long2),signal_long1);
final_signal_short = intersect(intersect(signal_short3,signal_short2),signal_short1);


% plot stoch1 signals
figure
plot(cl,'LineWidth',1.5)
hold on
plot(final_signal_long,cl(final_signal_long),'og','markersize',5,'LineWidth',2)
plot(final_signal_short,cl(final_signal_short),'or','markersize',5,'LineWidth',2)
% plot(signal_long1,cl(signal_long1),'og','markersize',3,'LineWidth',2)
% plot(signal_short1,cl(signal_short1),'or','markersize',3,'LineWidth',2)
% plot(signal_long2,cl(signal_long2),'og','markersize',4,'LineWidth',2)
% plot(signal_short2,cl(signal_short2),'or','markersize',4,'LineWidth',2)
% plot(signal_long3,cl(signal_long3),'og','markersize',5,'LineWidth',2)
% plot(signal_short3,cl(signal_short3),'or','markersize',5,'LineWidth',2)
title('stochastic oscillator, signal FpK only')

