% fai girare prima bkt offline
% poi le prime due parti del bkt demo
% poi lancia questo


comparison(:,1)=iOpen(1:end-1);
comparison(:,2)=bkt_Algo002twobound.iOpen;
comparison(:,3)=comparison(:,1)-comparison(:,2);

comparison(:,4)=iClose(1:end-1);
comparison(:,5)=bkt_Algo002twobound.iClose;
comparison(:,6)=comparison(:,5)-comparison(:,4);

comparison(:,7)=jClose(1:end-1);
comparison(:,8)=bkt_Algo002twobound.jClose;
comparison(:,9)=comparison(:,7)-comparison(:,8);


comparison(:,10)=floor(standev(iOpen(1:end-1)));
comparison(:,11)=bkt_Algo002twobound.stopL;
comparison(:,12)=comparison(:,10)-comparison(:,11);

comparison(:,13)=floor(5*standev(iOpen(1:end-1)));
comparison(:,14)=bkt_Algo002twobound.takeP;
comparison(:,15)=comparison(:,13)-comparison(:,14);

comparison(:,16)=outputmio(1:end-1,2);
comparison(:,17)=bkt_Algo002twobound.outputBktOffline(:,2);
comparison(:,18)=comparison(:,16)-comparison(:,17);

comparison(:,19)=outputmio(1:end-1,3);
comparison(:,20)=bkt_Algo002twobound.outputBktOffline(:,3);
comparison(:,21)=comparison(:,19)-comparison(:,20);

comparison(:,22)=outputmio(1:end-1,5);
comparison(:,23)=bkt_Algo002twobound.outputBktOffline(:,5);
comparison(:,24)=comparison(:,22)-comparison(:,23);