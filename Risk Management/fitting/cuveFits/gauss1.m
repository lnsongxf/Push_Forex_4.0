function g=gauss1(v,x)

A    = v(1);
W    = v(2);
Xo   = v(3);
back = 0.000000 ;
g=back+(A/(W.*sqrt(2*pi)))*(exp((-(x-Xo).^2)/(2*W.^2)));
