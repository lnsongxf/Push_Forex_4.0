function cointegrationTests(asset1,asset2)

x=asset1;
y=asset2;

plot(x);
hold on;
plot(y, 'g');

legend('asset1', 'asset2');

%% Plotta lo scatterplot di un asset vs il secondo asset
figure;

scatter(x, y);

%% Calcola l'hedge ratio ottimale e plottalo x veder se è stazionario
figure;

regression_result=ols(y, [x ones(size(x))]);
hedgeRatio=regression_result.beta(1);

plot(y-hedgeRatio*x);

%% Compute the CADF test (occhio che se scambi y e x il risultato cambia!)
% Assume a non-zero offset but no drift, with lag=1.

display('CADF test con il primo asset in input come variabile dipendente')
resultsX=cadf(x, y, 0, 1); % We pick x to be the dependent variable.

% Print out results
prt(resultsX);


display('CADF test con il secondo asset in input come variabile dipendente')
resultsY=cadf(y, x, 0, 1); % We pick y to be the dependent variable.

% Print out results
prt(resultsY);



%% Calculate the Johansen test
% Combine the two time series into a matrix y2 for input into Johansen test
y2=[y, x];
results=johansen(y2, 0, 1); % johansen test with non-zero offset but zero drift, and with the lag k=1.

display('---Johansen test---')
display('(il test deve dare valori superiori a 90% o più per tutti gli r)')
% Print out results
prt(results);



%% come aggiungere un terzo asset:

% facciamo che aggiungo un asset z
% 
% y3=[y2, z];
% 
% results=johansen(y3, 0, 1); % johansen test with non-zero offset but zero drift, and with the lag k=1.
% 
% % Print out results
% prt(results);

% 
% results.eig % Display the eigenvalues
% 
% results.evec % Display the eigenvectors
%     
% yport=sum(repmat(results.evec(:, 1)', [size(y3, 1) 1]).*y3, 2); % (net) market value of portfolio
% 
% % Find value of lambda and thus the halflife of mean reversion by linear regression fit
% ylag=lag(yport, 1);  % lag is a function in the jplv7 (spatial-econometrics.com) package.
% deltaY=yport-ylag;
% deltaY(1)=[]; % Regression functions cannot handle the NaN in the first bar of the time series.
% ylag(1)=[];
% regress_results=ols(deltaY, [ylag ones(size(ylag))]); % ols is a function in the jplv7 (spatial-econometrics.com) package.
% halflife=-log(2)/regress_results.beta(1);
% 
% fprintf(1, 'halflife=%f days\n', halflife);
