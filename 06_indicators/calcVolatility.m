clear volat2
clear volat_day
clear price_i
clear price_j

dati_inp = hisDataTest(1963:end,4);
%dati = dati_inp(1:10:end);
dati = dati_inp;
daypoints = 1436; %nr di dati ogni gg

sizeH = length(dati);
volat2 = zeros(sizeH,1);


price_i =  dati(2:end);
price_j =  dati(1:end-1);
ritorni_i = (price_i - price_j ) ./ price_j ;

for i = 10 : sizeH-1
    
    volat2(i) = var ( log ( 1 + ritorni_i(i-9:i) ) );

end

ngg = 50;
%ngg = floor(length(volat2)/daypoints);


volat_day = zeros(daypoints,1);
volat_day_mat = zeros(daypoints,ngg);



for j = 0 : ngg-1
    
    iniz = j*daypoints +1;
    fine = (j+1)*daypoints;
    
    volat_day = volat_day + volat2(iniz:fine);
    volat_day_mat(:,j+1) = volat2(iniz:fine);
    
end

volat_day = volat_day/ ngg;

area=trapz(1:daypoints,volat_day);
timeaxis = transpose(1:daypoints)/daypoints*24;

cla
pcolor(transpose(volat_day_mat/area*100));figure(gcf)
shading interp

% figure
% plot(timeaxis,volat_day/area*100)
% 
% volat2_sm = smooth(volat2,20);
% 
% figure
% plot(volat2_sm(1:daypoints),'r')
% hold on
% plot(volat2_sm(daypoints*100+1:daypoints*101),'b')
% plot(volat2_sm(daypoints*200+1:daypoints*201),'k')
% plot(volat2_sm(daypoints*300+1:daypoints*301),'g')
% plot(volat2_sm(daypoints*250+1:daypoints*251),'y')

