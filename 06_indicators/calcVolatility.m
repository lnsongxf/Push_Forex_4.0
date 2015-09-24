clear volat2
clear volat_day
clear price_i
clear price_j

%% input data
[~, ~, hisData] = xlsread('EURUSD_2012_2015_withDate_corretto.csv');
%hisData(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),hisData)) = {'NaN'};
actTimeScale = 1;
newTimeScale = 30;

[RigheStorico,ColonneStorico] = size(hisData);


% incazzati se non esiste colonna 6 delle date nello storico
if ColonneStorico < 6
    
display('NON VEDO LE DATE!!')
% stoppa tutto...
    
end

%% crea matrice divisa per settimane

nSetti = 7141; % numero di punti al minuto ogni settimana
Settimane = ceil(RigheStorico/nSetti); % numero di settimane
MatriceSettimane=NaN(nSetti,Settimane);
gg=1;
chiusure=cell2mat(hisData( : , 4 ));

while gg < RigheStorico

    if strcmp(datestr(hisData{gg,6},'ddd'),'Mon')

        for c=1:floor((RigheStorico-gg)/nSetti)
            
            MatriceSettimane(1:nSetti,c) = chiusure( (gg+(c-1)*nSetti+1):(gg+c*nSetti) );
            display(hisData{(gg+(c-1)*nSetti+1),6})
            %display(hisData{(gg+c*nSetti),6})

        end
        
        break

    end
    
    gg=gg+1;
        
end
    
MatriceSettimane(MatriceSettimane==0)=NaN;

%% riscala temporalmente la matrice se richiesto
    
if newTimeScale > 1
    
    MatriceNewTimeScale = MatriceSettimane(1:newTimeScale:end,:);

else
    
    MatriceNewTimeScale = MatriceSettimane;
    
end

%% calcola volatilità settimanale

[newRighe,newColonne] = size(MatriceNewTimeScale);

newColonne = 50; % cancellami

price_i =  MatriceNewTimeScale(2:end,:);
price_j =  MatriceNewTimeScale(1:end-1,:);
ritorni_i = (price_i - price_j ) ./ price_j ;

volat2 = zeros(newRighe,newColonne);

for col = 1 : newColonne
    
    for i = 10 : newRighe-1
        
        volat2(i,col) = var ( log ( 1 + ritorni_i(i-9:i,col) ) );
        
    end
    
end


%%

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

