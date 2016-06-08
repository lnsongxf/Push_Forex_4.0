function [d,Pp]=errorP(nExtract)

n=nExtract;

Nm=zeros(n,5);
Rm=zeros(n,5);

for i = 1:100
    N=randn(n,1);
    Nm(:,2)=N;
    [state,P]=anderson(Nm,0.5);
    Pp(i)=P;
    R=rand(n,1);
    Rm(:,2)=R;
    [state,R]=anderson(Rm,0.5);
    Rr(i)=R;
end

PpM=mean(Pp);
RrM=mean(Rr);

d=PpM-RrM;

plot(Pp,'-ob');
hold on
plot(Rr,'-or');