function g=lognormale(v,x)

A    = v(1);
W    = v(2);
Xo   = v(3);

x=x+1;

back = 0.000000 ;
den=x.*(W*sqrt(2*pi));
l=log(x);
num1=-((l-Xo).^2);
num2=2*(W.^2);
e=exp(num1./num2);
num=A*e;
g=back+num./den;
