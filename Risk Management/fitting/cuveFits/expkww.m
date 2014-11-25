function y=expkww(v,t)

%y01 = v(1);
y02 = v(1);
t0 = v(2);
beta = v(3);


%y=y01+y02.*(exp(-((t./t0).^beta)));
y=y02.*(exp(-((t./t0).^beta)));
%y=exp(-((t./t0).^beta));