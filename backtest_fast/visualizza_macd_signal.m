figure
ax(1)=subplot(2,1,1);
plot(chiusure)
ax(2)=subplot(2,1,2);
plot(signal,'r')
refline(0)
linkaxes(ax,'x')

%%
 [macdvec, nineperma] = macd(chiusure);
signal=macdvec-nineperma;
signal(signal>0)=1;
signal(signal<0)=-1;
esse=signal(2:end)+signal(1:end-1);
indexesse=find(esse==0);
%%

figure

plot(chiusure,'LineWidth',2)
hold on
plot(indexesse,chiusure(indexesse),'or','markersize',5,'LineWidth',2)


%%

indexplus = find(signal==1);
indexminus = find(signal==-1);

figure
plot(chiusure,'LineWidth',1.5)
hold on
plot(indexplus,chiusure(indexplus),'og','markersize',3,'LineWidth',2)
plot(indexminus,chiusure(indexminus),'or','markersize',3,'LineWidth',2)