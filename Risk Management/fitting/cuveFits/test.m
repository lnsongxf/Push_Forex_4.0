function g=test(v,x)

p1    = v(1);
p2    = v(2);
p3   = v(3);
back = v(4) ;
g=back+p1.*p2.^(p3-x);