function g8=gauss8(v,x)

A0    = v(1);
W0    = v(2);
Xo0   = v(3);
back0 = 0.000000 ;
g0=back0+(A0/(W0.*sqrt(2*pi)))*(exp((-(x-Xo0).^2)/(2*W0.^2)));

A1    = v(4);
W1    = v(5);
Xo1   = v(6);
back1 = 0.000000 ;
g1=back1+(A1/(W1.*sqrt(2*pi)))*(exp((-(x-Xo1).^2)/(2*W1.^2)));

A2    = v(7);
W2    = v(8);
Xo2   = v(9);
back2 = 0.000000 ;
g2=back2+(A2/(W2.*sqrt(2*pi)))*(exp((-(x-Xo2).^2)/(2*W2.^2)));

A3    = v(10);
W3    = v(11);
Xo3   = v(12);
back3 = 0.000000 ;
g3=back3+(A3/(W3.*sqrt(2*pi)))*(exp((-(x-Xo3).^2)/(2*W3.^2)));

A4    = v(13);
W4    = v(14);
Xo4   = v(15);
back4 = 0.000000 ;
g4=back4+(A4/(W4.*sqrt(2*pi)))*(exp((-(x-Xo4).^2)/(2*W4.^2)));

A5    = v(16);
W5    = v(17);
Xo5   = v(18);
back5 = 0.000000 ;
g5=back5+(A5/(W5.*sqrt(2*pi)))*(exp((-(x-Xo5).^2)/(2*W5.^2)));

A6    = v(19);
W6    = v(20);
Xo6   = v(21);
back6 = 0.000000 ;
g6=back6+(A6/(W6.*sqrt(2*pi)))*(exp((-(x-Xo6).^2)/(2*W6.^2)));

A7    = v(22);
W7    = v(23);
Xo7   = v(24);
back7 = 0.000000 ;
g7=back7+(A7/(W7.*sqrt(2*pi)))*(exp((-(x-Xo7).^2)/(2*W7.^2)));

g8 = g0+g1+g2+g3+g4+g5+g6+g7;

