function g8bb=gauss8bb(v,x)

A0    = v(1);
W0    = v(2);
Xo0   = 18.5187;
back0 = 0.000000 ;
g0=back0+(A0/(W0.*sqrt(2*pi)))*(exp((-(x-Xo0).^2)/(2*W0.^2)));

A1    = v(3);
W1    = v(4);
Xo1   = 20.12;
back1 = 0.000000 ;
g1=back1+(A1/(W1.*sqrt(2*pi)))*(exp((-(x-Xo1).^2)/(2*W1.^2)));

A2    = v(5);
W2    = v(6);
Xo2   = 20.7;
back2 = 0.000000 ;
g2=back2+(A2/(W2.*sqrt(2*pi)))*(exp((-(x-Xo2).^2)/(2*W2.^2)));

A3    = v(7);
W3    = v(8);
Xo3   = 22.68;
back3 = 0.000000 ;
g3=back3+(A3/(W3.*sqrt(2*pi)))*(exp((-(x-Xo3).^2)/(2*W3.^2)));

A4    = v(9);
W4    = v(10);
Xo4   = 22.97;
back4 = 0.000000 ;
g4=back4+(A4/(W4.*sqrt(2*pi)))*(exp((-(x-Xo4).^2)/(2*W4.^2)));

A5    = v(11);
W5    = v(12);
Xo5   = 23.46;
back5 = 0.000000 ;
g5=back5+(A5/(W5.*sqrt(2*pi)))*(exp((-(x-Xo5).^2)/(2*W5.^2)));

A6    = v(13);
W6    = v(14);
Xo6   = 24.24;
back6 = 0.000000 ;
g6=back6+(A6/(W6.*sqrt(2*pi)))*(exp((-(x-Xo6).^2)/(2*W6.^2)));

A7    = v(15);
W7    = v(16);
Xo7   = 25.22;
back7 = 0.000000 ;
g7=back7+(A7/(W7.*sqrt(2*pi)))*(exp((-(x-Xo7).^2)/(2*W7.^2)));


c0=v(17);
c1=v(18);
c2=v(19);
gpow = c0 + c1*x.^c2;

g8bb=  gpow + g0+g1+g2+g3+g4+g5+g6+g7;

