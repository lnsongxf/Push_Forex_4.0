function y=exponential(v,x)

back0 = v(1);
A0    = v(2);
x0    = v(3);

y=back0+A0*(exp(-x/x0));

