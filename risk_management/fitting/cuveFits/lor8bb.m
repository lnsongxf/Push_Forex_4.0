function l8bb=lor8bb(v,x)

A0    = v(1);
W0    = v(2);
Xo0   = 18.5187;
back0 = 0.000000 ;
l0=back0+ (A0/pi)*(W0./(((x-Xo0).^2)+W0.^2));

A1    = v(3);
W1    = v(4);
Xo1   = 20.12;
back1 = 0.000000 ;
l1=back1+ (A1/pi)*(W1./(((x-Xo1).^2)+W1.^2));

A2    = v(5);
W2    = v(6);
Xo2   = 20.7;
back2 = 0.000000 ;
l2=back2+ (A2/pi)*(W2./(((x-Xo2).^2)+W2.^2));

A3    = v(7);
W3    = v(8);
Xo3   = 22.68;
back3 = 0.000000 ;
l3=back3+ (A3/pi)*(W3./(((x-Xo3).^2)+W3.^2));

A4    = v(9);
W4    = v(10);
Xo4   = 22.97;
back4 = 0.000000 ;
l4=back4+ (A4/pi)*(W4./(((x-Xo4).^2)+W4.^2));

A5    = v(11);
W5    = v(12);
Xo5   = 23.46;
back5 = 0.000000 ;
l5=back5+ (A5/pi)*(W5./(((x-Xo5).^2)+W5.^2));

A6    = v(13);
W6    = v(14);
Xo6   = 24.24;
back6 = 0.000000 ;
l6=back6+ (A6/pi)*(W6./(((x-Xo6).^2)+W6.^2));

A7    = v(15);
W7    = v(16);
Xo7   = 25.22;
back7 = 0.000000 ;
l7=back6+ (A7/pi)*(W7./(((x-Xo7).^2)+W7.^2));

Ab    = v(17);
Wb    = v(18);
Xob   = v(19);
backb = 0;
gb=backb+(Ab/(Wb.*sqrt(2*pi)))*(exp((-(x-Xob).^2)/(2*Wb.^2)));

c0=v(20);
c1=v(21);
c2=v(22);
pow = c0 + c1*x.^c2;

l8bb= gb + pow + l0+l1+l2+l3+l4+l5+l6+l7;

