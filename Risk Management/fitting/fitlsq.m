function [vEnd_f, yEnd_f, v, vin, vfin,R] = fitlsq(n,x,y,fun,v,vin,vfin,A)

% [vEndx,resids,J] = nlinfit(x,Antellawm5_kde,@lognorm,v);
% plot(x,lognorm(vEndx,x));

% [vEndx,resids,J] = nlinfit(x,frame190,@gauss8,v);
% plot(x,gauss8(vEndx,x));

for i=1:n

%cla;

y_f = y(:,i);
%%
%%-----nlin fit------------
% [vEnd,resids,J]=nlinfit(x,y_f,fun,v);
% yEnd=fun(vEnd,x);
% vEnd_f(i,:)=vEnd;
% yEnd_f(:,i)=yEnd;

%%
%%----lsqcurvefit fit------
[vEnd,resnorm,resids,exitflag,output,lambda,J]=lsqcurvefit(fun,v,x,y_f,vin,vfin);
yEnd=fun(vEnd,x);
vEnd_f=[n,2];
vEnd_f(i,:)=vEnd;
yEnd_f(:,1)=yEnd;    %mettere al posto di 1 i se hai serie di FIT

R=resnorm;

v=vEnd_f(i,:);

v(1)=A;
%%
%%
% vin=  [v(1:16)-0.25*v(1:16) v(17:19)-0.001*v(17:19) v(20:21)-0.002*v(20:21) v(22)+0.002*v(22)];
% vfin= [v(1:16)+0.25*v(1:16) v(17:19)+0.001*v(17:19) v(20:21)+0.002*v(20:21) v(22)-0.002*v(22)];

% vin=  [v(1)-0.0001*v(1) v(2)-0.99*v(2)];
% vfin= [v(1)+0.0001*v(1) v(2)+0.99*v(2)];

vUp=abs(0.01*v(1));

vin=  [v(1)-vUp v(2)-0.99*v(2)];
vfin= [v(1)+vUp v(2)+0.99*v(2)];

% 
% 
%                 display(vin)
%                 display(vfin)
% 
%                 display(A)

% funzionicchia con v(17)=A3;
% vin=  [v(1:16)-0.4*v(1:16) v(17)-0.0001*v(17)  v(18)-0.05*v(18) v(19)-0.0005*v(19) v(20:21)-0.05*v(20:21) v(22)+0.05*v(22)];
% vfin= [v(1:16)+0.4*v(1:16) v(17)+0.0001*v(17)  v(18)+0.05*v(18) v(19)+0.0005*v(19) v(20:21)+0.05*v(20:21) v(22)-0.05*v(22)];

% vin=  [v(1:16)-0.30*v(1:16)  v(17:18)-0.001*v(17:18) v(19)+0.001*v(19)];
% vfin= [v(1:16)+0.30*v(1:16)  v(17:18)+0.001*v(17:18) v(19)-0.001*v(19)];

%%
%%

%%
%%errors---------
% ci = nlparci(vEnd,resids,J);
% err=zeros(n,size(ci(1)));
% %for r=1:19
% for r=1:size(ci(1))        %modificato
%     err(i,r)=(ci(r,2)-ci(r,1))/2;
% end;
%%
%%
% loglog(x,y(:,i),'or');
% hold on;
% loglog(x,yEnd_f(:,i),'-b');
% loglog(x,(pow(v(20:22),x)));
% %loglog(x,(pow(v(17:19),x)));
% loglog(x,(powgauss1(v(17:22),x)));
% %loglog(x,(gauss1(v(17:19),x)));
pause(0.05);
%%
%%
end;