function L1=linear1(v,x)

% [vEnd,resids,J]=nlinfit(x,y,@linear1,inFit);
% plot(x,linear1(vEnd,x));
%

m0    = v(1);
back0 = v(2) ;

L1=back0+m0.*x;
%L1=L1';
