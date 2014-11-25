function w = som(data)
%//Matlab script
%//-- 10 x 10 map
%// data è un vettore colonna

data = double(data);
%// numero totale dei nodi
totalW = 100;
%//inizializazione dei pesi. matrice (900*100)
w = rand(900, totalW);
%// learning rate iniziale
eta0 = 0.1;
%// learning rate (updated every epoch)
etaN = eta0;
%// costante per calcolare il learning rate
tau2 = 1000;

%//map index - matrice 10*10 - ind2sub restituisce gli indici della matrice
%che utilizzo in seguito per metterci dentro i valori
[I,J] = ind2sub([10, 10], 1:100);

%//restituisce la dimensione della matrice individuata dallo scalare 2. es:
%una matrice (2,4,3)->restituisce 4. In questo caso abbiamo un vettore
%colonna data e restituisce la dimensione del vettore
N = size(data,2);

alpha = 0.5;
%// dimensione dei vicini
sig0 = 200;

sigN = sig0;
%// tau1 per aggiornare il sigma
tau1 = 1000/log(sigN);

%i numero di epoch
for i=1:2000
    for j=1:N
        x = data(:,j);
        
      %   w =

   % 0.0357
   % 0.8491
   % 0.9340

%repmat(w,1,4)

%ans =
%
%    0.0357    0.0357    0.0357    0.0357
%    0.8491    0.8491    0.8491    0.8491
%    0.9340    0.9340    0.9340    0.9340
        
        
        dist = sum( sqrt((w - repmat(x,1,totalW)).^2),1);

        %// trova il winner -> restituisce l'indice del vincitore all
        %'interno della matrice dist (900*100)
        [v ind] = min(dist);
        %// the 2-D index - prendo la colonna dove è contenuto il vincitore
        ri = [I(ind), J(ind)];

        %// distanza dal vincitore
        dist = 1/(sqrt(2*pi)*sigN).*exp( sum(( ([I( : ), J( : )] - repmat(ri, totalW,1)) .^2) ,2)/(-2*sigN)) * etaN;

        %// aggiornamento pesi
        for rr = 1:100
            w(:,rr) = w(:,rr) + dist(rr).*( x - w(:,rr));
        end
    end

    %// aggiorna il learning rate
    etaN = eta0 * exp(-i/tau2);
    %// aggiorna il sigma
    %sigN = sigN/2;
    sigN = sig0*exp(-i/tau1);

    %//mostra i mesi ogni 100 epoch
    if mod(i,200) == 1
        plot(w(:,1),w(:,2),'s');
        display('');
        figure;
        axis off;
        hold on;
        %//for l = 1:100
           %// [lr lc] = ind2sub([10, 10], l);
           %// subplot(10,10,l);
           %// axis off;
          %//  imagesc(reshape(w(:,l),30,30));
          %//  axis off;
       %// end
        hold off;
    end
end