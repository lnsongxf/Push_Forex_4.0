function [vEnd_f, yEnd_f, err] = fit2D(n,x,y,fun,v)

%%
% n numero di serie da fittare (nel caso i valori fossero allocarti in
% colenne di una matrice)
%
% v parametri iniziali del fit
%%


% [vEndx,resids,J] = nlinfit(x,Antellawm5_kde,@lognorm,v);
% plot(x,lognorm(vEndx,x));

% [vEndx,resids,J] = nlinfit(x,frame190,@gauss8,v);
% plot(x,gauss8(vEndx,x));

for i=1:n
    
%cla;

y_f = y(:,i);
%%
%%-----nlin fit------------
[vEnd,resids,J]=nlinfit(x,y_f,fun,v);

yEnd=fun(vEnd,x);    %aggiunto fix
%vEnd_f=[n,2];
vEnd_f(i,:)=vEnd;
yEnd_f(:,i)=yEnd;   %mettere al posto di 1 i se hai serie di FIT


%%
%%----lsqcurvefit fit------
% [vEnd,resnorm,resids,exitflag,output,lambda,J]=lsqcurvefit(@powgauss1,v,x,y_f,vin,vfin);
% yEnd=powgauss1(vEnd,x);
% vEnd_f(i,:)=vEnd;
% yEnd_f(:,i)=yEnd;

%%
%%--------errors---------
% npar=30;
ci = nlparci(vEnd,resids,J);
err=zeros(n,size(ci(1)));
for r=1:size(ci(1))        %modificato
    err(i,r)=(ci(r,2)-ci(r,1))/2;
end;
%%
% plot(x,y(:,i),'or');
% hold on;
% plot(x,yEnd_f(:,i),'-b');

pause(0.05);
%%
end;