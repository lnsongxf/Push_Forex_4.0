function l=lor1(v,x)

A    = v(1);
W    = v(2);
Xo   = v(3);
back = 0.000000 ;
l=back+ (A/pi)*(W./(((x-Xo).^2)+W.^2));
