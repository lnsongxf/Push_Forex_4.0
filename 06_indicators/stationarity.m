classdef stationarity <handle
    properties
        HurstExponent
        pValue
        halflife
    end
    
    methods
        function obj = stationarityTests(obj,closeprices,timescale,plotValues)
            
            %
            % DESCRIPTION:
            % -----------------------------------------------------------------------
            % This function calculates several parameters for evaluating the stationarity hypotesis:
            %
            % INPUT parameters:
            % -----------------------------------------------------------------------
            % closeprices       ... closure prices used in the Algo
            % timescale         ... 1 time-scale used
            % plotValues        ... 1-visualize the paramenters value
            %
            % OUTPUT parameters:
            % -----------------------------------------------------------------------
            % HurstExponent     ... Hurst's exponent: H2 < 0.5 -> mean reverting, H2 > 0.5 -> trending
            % pValue            ... the probability that the null hypothesis (random walk) is true
            % halflife          ... average duration of fluctuations in
            %                       mean reversion regime
            %
            % EXAMPLE of use:
            % -----------------------------------------------------------------------
            % st=stationarity
            % st=st.stationarityTests(bkt_Algo002.newHisData(1:500,4),30,1)
            %
            
            %% adf test (confronta la t-statistics con i valori critici)
            % Assume a non-zero offset but no drift, with lag=1.
            results=adf(closeprices, 0, 1);
            
            if plotValues
                % Print out results
                prt(results);
                plot(closeprices);
            end
            
            %% Find Hurst exponent
            
            obj.HurstExponent=genhurst(log(closeprices), 1);
            if plotValues
                %             display('---Generalized Hurst exponent---')
                %             display('(H2 < 0.5 -> mean reverting)')
                %             display('(H2 > 0.5 -> trending)')
                fprintf(1, 'H2=%f\n', obj.HurstExponent);
                display(' ')
            end
            
            %% Variance ratio test from Matlab Econometrics Toolbox
            [~,obj.pValue]=vratiotest(log(closeprices));
            if plotValues
                %             display('---Variance ratio test---')
                %             display('(h=1 means rejection of random walk hypothesis)')
                %             fprintf(1, 'h=%i\n', h); % h=1 means rejection of random walk hypothesis, 0 means it is a random walk.
                %             display('probability that the prices follow a random walk:')
                fprintf(1, 'pValue=%f\n', obj.pValue); % pValue is essentially the probability that the null hypothesis (random walk) is true.
                display(' ')
            end
            
            %% compute the half-life of mean reversion
            % Find value of lambda and thus the halflife of mean reversion by linear regression fit
            ylag=lag(closeprices, 1);
            deltaY=closeprices-ylag;
            deltaY(1)=[]; % Regression functions cannot handle the NaN in the first bar of the time series.
            ylag(1)=[];
            regress_results=ols(deltaY, [ylag ones(size(ylag))]);
            obj.halflife=-log(2)/regress_results.beta(1);
            
            if plotValues
                %             display('---Estimated half-life of mean reversion---')
                fprintf(1, 'halflife=%f riferito alla timescale %i\n', obj.halflife, timescale);
                display(' ')
            end
        end
        
    end
end