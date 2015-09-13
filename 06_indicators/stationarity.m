classdef stationarity <handle
    properties
        HurstExponent
        pValue
        halflife
    end
    
    methods
        function stationarityTests(obj,closeprices, timescale)
            
            plot(closeprices);
            
            %% adf test (confronta la t-statistics con i valori critici)
            % Assume a non-zero offset but no drift, with lag=1.
            results=adf(closeprices, 0, 1);
            
            % Print out results
            prt(results);
            
            
            %% Find Hurst exponent
            
            obj.HurstExponent=genhurst(log(closeprices), 2);
            display('---Generalized Hurst exponent---')
            display('(H2 < 0.5 -> mean reverting)')
            display('(H2 > 0.5 -> trending)')
            fprintf(1, 'H2=%f\n', obj.HurstExponent);
            display(' ')
            
            %% Variance ratio test from Matlab Econometrics Toolbox
            [h,obj.pValue]=vratiotest(log(closeprices));
            
            display('---Variance ratio test---')
            display('(h=1 means rejection of random walk hypothesis)')
            fprintf(1, 'h=%i\n', h); % h=1 means rejection of random walk hypothesis, 0 means it is a random walk.
            display('probability that the prices follow a random walk:')
            fprintf(1, 'pValue=%f\n', obj.pValue); % pValue is essentially the probability that the null hypothesis (random walk) is true.
            display(' ')
            
            %% compute the half-life of mean reversion
            % Find value of lambda and thus the halflife of mean reversion by linear regression fit
            ylag=lag(closeprices, 1);
            deltaY=closeprices-ylag;
            deltaY(1)=[]; % Regression functions cannot handle the NaN in the first bar of the time series.
            ylag(1)=[];
            regress_results=ols(deltaY, [ylag ones(size(ylag))]);
            obj.halflife=-log(2)/regress_results.beta(1);
            
            display('---Estimated half-life of mean reversion---')
            fprintf(1, 'halflife=%f riferito alla timescale %i\n', obj.halflife, timescale);
            display(' ')
        end
        
    end
end