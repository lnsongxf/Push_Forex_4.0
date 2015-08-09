% fai girare prima bkt offline
% poi le prime due parti del bkt demo
% poi lancia questo


comparison(:,1)=iOpen(1:end);
% comparison(:,2)=bkt_Algo002aa.iOpenNewTimeScale;
% comparison(:,3)=comparison(:,1)-comparison(:,2);

comparison(:,4)=iClose(1:end);
% comparison(:,5)=bkt_Algo002aa.iCloseNewTimeScale;
% comparison(:,6)=comparison(:,5)-comparison(:,4);

comparison(:,7)=jClose(1:end);
% comparison(:,8)=bkt_Algo002aa.iCloseActTimeScale;
% comparison(:,9)=comparison(:,7)-comparison(:,8);


comparison(:,10)=floor(standev(iOpen(1:end)));
% comparison(:,11)=bkt_Algo002aa.stopL;
% comparison(:,12)=comparison(:,10)-comparison(:,11);

comparison(:,13)=floor(5*standev(iOpen(1:end)));
% comparison(:,14)=bkt_Algo002aa.takeP;
% comparison(:,15)=comparison(:,13)-comparison(:,14);

comparison(:,16)=outputmio(1:end,2);
% comparison(:,17)=bkt_Algo002aa.outputBktOffline(:,2);
% comparison(:,18)=comparison(:,16)-comparison(:,17);

comparison(:,19)=outputmio(1:end,3);
% comparison(:,20)=bkt_Algo002aa.outputBktOffline(:,3);
% comparison(:,21)=comparison(:,19)-comparison(:,20);

comparison(:,22)=outputmio(1:end,5);
% comparison(:,23)=bkt_Algo002aa.outputBktOffline(:,5);
% comparison(:,24)=comparison(:,22)-comparison(:,23);