v = csvread('EURUSD1.csv');
v = v(:,4);

for i = 1 : 60 : 12000
    
    v1 = v(10000+i:10360+i);
    fourierApp(v1,3);
    pause(1);
end