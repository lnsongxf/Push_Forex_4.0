
[hisData, newHisData] = load_historical('AUDCAD.csv', 1, 30);

Price = newHisData(1:5000,4);
mu = mean(Price);
standev = std(Price);
P = (Price - mu) / standev; %% scalato per velocizzare il fit

npunti = 100;
nlead10 = 10;
nlead15 = 15;
nlead20 = 20;

angCoeff = zeros(length(P),1);
ordinata = zeros(length(P),1);
movingFit1 = zeros(length(P),1);
movingFit2 = zeros(length(P),1);
movingFit3 = zeros(length(P),1);
movingLead10 = zeros(length(P),1);
movingLead15 = zeros(length(P),1);
movingLead20 = zeros(length(P),1);
sigma10 = zeros(length(P),1);
mean10 = zeros(length(P),1);
sigma15 = zeros(length(P),1);
mean15 = zeros(length(P),1);
sigma20 = zeros(length(P),1);
mean20 = zeros(length(P),1);


for i=npunti:length(P)
    
    %%%% prova di fit con diversi polinomi
    
    a(:,1)=i-(npunti-1):i;
    
    myf1=fit( a , P(a) , 'poly1');
    angCoeff(i) = myf1.p1;
    ordinata(i) = myf1.p2;
    movingFit1(i) = angCoeff(i)*i + ordinata(i);
    myf2=fit( a , P(a) , 'poly2');
    movingFit2(i) = myf2.p1*i^2 + myf2.p2*i + myf2.p3;
    myf3=fit( a , P(a) , 'poly3');
    movingFit3(i) = myf3.p1*i^3 + myf3.p2*i^2 + myf3.p3*i + myf3.p4;
    
    %%%% prova fit lineare con diverse finestre
    
    b10(:,1)=i-(nlead10-1):i;
    b15(:,1)=i-(nlead15-1):i;
    b20(:,1)=i-(nlead20-1):i;
    
    myf10lead=fit( b10 , P(b10) , 'poly1');
    movingLead10(i) = myf10lead.p1*i + myf10lead.p2;
    myf15lead=fit( b15 , P(b15) , 'poly1');
    movingLead15(i) = myf15lead.p1*i + myf15lead.p2;
    myf20lead=fit( b20 , P(b20) , 'poly1');
    movingLead20(i) = myf20lead.p1*i + myf20lead.p2;
    
    
end

%riscala ai valori corretti del cross

movingFit1 = movingFit1 * standev + mu;
angCoeff = angCoeff * standev + mu;
ordinata = ordinata * standev + mu;
movingFit2 = movingFit2 * standev + mu;
movingFit3 = movingFit3 * standev + mu;
movingLead10 = movingLead10 * standev + mu;
movingLead15 = movingLead15 * standev + mu;
movingLead20 = movingLead20 * standev + mu;

% calcola derivate varie

deriv100 = [0 ; diff(angCoeff)];
derivLead10 = [0 ; diff(movingLead10)];
derivLead15 = [0 ; diff(movingLead15)];
derivLead20 = [0 ; diff(movingLead20)];

% deriv100Bin=deriv100;
% deriv100Bin(find(deriv100<0))=-1;
% deriv100Bin(find(deriv100>=0))=1;
% diffDeriv100Bin=[0; diff(deriv100Bin)];  % =2 quando passa da neg a pos, e viceversa

for j=80:length(P)
    
    sigma10(j) = std( derivLead10(j-20:j) ); % calcolo le statistiche usando una finestra 2x quella del fit
    mean10(j) = mean( derivLead10(j-20:j) );
    sigma15(j) = std( derivLead15(j-30:j) );
    mean15(j) = mean( derivLead15(j-30:j) );
    sigma20(j) = std( derivLead20(j-40:j) );
    mean20(j) = mean( derivLead20(j-40:j) );
    
end

% plotta prezzo e fit con diversi polinomi
figure
plot(Price)
hold on
plot(movingFit1,'r')
plot(movingFit2,'g')
plot(movingFit3,'b')
legend('Price','linear','poly2','poly3')
title(['fit con differenti polinomi, finestra ',num2str(npunti)])


% plotta 1) prezzo e fit lineare, 2) coeff angolare del fit, 3) derivata del coeff
figure
su(1)=subplot(3,1,1);
plot(Price)
hold on
plot(movingFit1,'r')
su(2)=subplot(3,1,2);
plot(angCoeff)
su(3)=subplot(3,1,3);
plot(deriv100)
linkaxes(su,'x')

% plotta 1) prezzo e fit lineari con finestra diversa, 2) coeff angolari dei fit
figure
suu(1)=subplot(2,1,1);
plot(Price)
hold on
plot(movingLead10,'g')
plot(movingLead15,'m')
plot(movingLead20,'k')
suu(2)=subplot(2,1,2);
plot(derivLead10,'g')
hold on
plot(derivLead15,'m')
plot(derivLead20,'k')
linkaxes(suu,'x')



% plotta 1) prezzo e fit10 lineare, 2) derivata del coeff con bande della distribuzione di probab della derivata
figure
ss(1)=subplot(2,1,1);
plot(Price)
hold on
plot(movingLead10,'g')
ss(2)=subplot(2,1,2);
plot(derivLead10)
hold on
plot( (mean10+sigma10), 'r')
plot( (mean10-sigma10), 'r')
linkaxes(ss,'x')

% plotta 1) prezzo e fit15 lineare, 2) derivata del coeff con bande della distribuzione di probab della derivata
figure
sss(1)=subplot(2,1,1);
plot(Price)
hold on
plot(movingLead15,'g')
sss(2)=subplot(2,1,2);
plot(derivLead15)
hold on
plot( (mean15+sigma15), 'r')
plot( (mean15-sigma15), 'r')
linkaxes(sss,'x')

% plotta 1) prezzo e fit20 lineare, 2) derivata del coeff con bande della distribuzione di probab della derivata
figure
su(1)=subplot(2,1,1);
plot(Price)
hold on
plot(movingLead20,'g')
su(2)=subplot(2,1,2);
plot(derivLead20)
hold on
plot( (mean20+sigma20), 'r')
plot( (mean20-sigma20), 'r')
linkaxes(su,'x')
