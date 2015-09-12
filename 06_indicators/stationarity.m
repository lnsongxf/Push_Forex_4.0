classdef stationarity <handle
    properties
        
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
            
            H=obj.genhurst(obj,log(closeprices), 2);
            display('---Generalized Hurst exponent---')
            display('(H2 < 0.5 -> mean reverting)')
            display('(H2 > 0.5 -> trending)')
            fprintf(1, 'H2=%f\n', H);
            display(' ')
            
            %% Variance ratio test from Matlab Econometrics Toolbox
            [h,pValue]=vratiotest(log(closeprices));
            
            display('---Variance ratio test---')
            display('(h=1 means rejection of random walk hypothesis)')
            fprintf(1, 'h=%i\n', h); % h=1 means rejection of random walk hypothesis, 0 means it is a random walk.
            display('probability that the prices follow a random walk:')
            fprintf(1, 'pValue=%f\n', pValue); % pValue is essentially the probability that the null hypothesis (random walk) is true.
            display(' ')
            
            %% compute the half-life of mean reversion
            % Find value of lambda and thus the halflife of mean reversion by linear regression fit
            ylag=lag(closeprices, 1);
            deltaY=closeprices-ylag;
            deltaY(1)=[]; % Regression functions cannot handle the NaN in the first bar of the time series.
            ylag(1)=[];
            regress_results=ols(deltaY, [ylag ones(size(ylag))]);
            halflife=-log(2)/regress_results.beta(1);
            
            display('---Estimated half-life of mean reversion---')
            fprintf(1, 'halflife=%f riferito alla timescale %i\n', halflife, timescale);
            display(' ')
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Calculates the generalized Hurst exponent H(q) from the scaling
        % of the renormalized q-moments of the distribution
        %
        %       <|x(t+r)-x(t)|^q>/<x(t)^q> ~ r^[qH(q)]
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % for the generalized Hurst exponent method please refer to:
        %
        %   T. Di Matteo et al. Physica A 324 (2003) 183-188
        %   T. Di Matteo et al. Journal of Banking & Finance 29 (2005) 827-851
        %   T. Di Matteo Quantitative Finance, 7 (2007) 21-36
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%    Tomaso Aste   30/01/2013     %%
        
        function [mH,sH]=genhurst(S,q,maxT)
            if nargin < 2, q = 1; maxT = 19; end
            if nargin < 3,  maxT = 19; end
            if size(S,1)==1 && size(S,2)>1
                S = S';
            elseif size(S,1)>1 && size(S,2)>1
                fprintf('S must be 1xT  \n')
                return
            end
            if size(S,1) < (maxT*4 | 60)
                warning('Data serie very short!') %#ok<WNTAG>
            end
            L=length(S);
            lq = length(q);
            H  = [];
            k = 0;
            for Tmax=5:maxT
                k = k+1;
                x = 1:Tmax;
                mcord = zeros(Tmax,lq);
                for tt = 1:Tmax
                    dV = S((tt+1):tt:L) - S(((tt+1):tt:L)-tt);
                    VV = S(((tt+1):tt:(L+tt))-tt)';
                    N = length(dV)+1;
                    X = 1:N;
                    Y = VV;
                    mx = sum(X)/N;
                    SSxx = sum(X.^2) - N*mx^2;
                    my   = sum(Y)/N;
                    SSxy = sum(X.*Y) - N*mx*my;
                    cc(1) = SSxy/SSxx;
                    cc(2) = my - cc(1)*mx;
                    ddVd  = dV - cc(1);
                    VVVd  = VV - cc(1).*(1:N) - cc(2);
                    %figure
                    %plot(X,Y,'o')
                    %hold on
                    %plot(X,cc(1)*X+cc(2),'-r')
                    %figure
                    %plot(1:N-1,dV,'ob')
                    %hold on
                    %plot([1 N-1],mean(dV)*[1 1],'-b')
                    %plot(1:N-1,ddVd,'xr')
                    %plot([1 N-1],mean(ddVd)*[1 1],'-r')
                    for qq=1:lq
                        mcord(tt,qq)=mean(abs(ddVd).^q(qq))/mean(abs(VVVd).^q(qq));
                    end
                end
                mx = mean(log10(x));
                SSxx = sum(log10(x).^2) - Tmax*mx^2;
                for qq=1:lq
                    my = mean(log10(mcord(:,qq)));
                    SSxy = sum(log10(x).*log10(mcord(:,qq))') - Tmax*mx*my;
                    H(k,qq) = SSxy/SSxx;
                end
            end
            %figure
            %loglog(x,mcord,'x-')
            mH = mean(H)'./q(:);
            if nargout == 2
                sH = std(H)'./q(:);
            elseif nargout == 1
                sH = [];
            end
            
        end
    end
end