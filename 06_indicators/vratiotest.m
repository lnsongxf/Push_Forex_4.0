function [h,pValue,stat,cValue,ratio] = vratiotest(y,varargin)
%VRATIOTEST Variance ratio test for a random walk.
%
% Syntax:
%
%   [h,pValue,stat,cValue,ratio] = vratiotest(y)
%   [h,pValue,stat,cValue,ratio] = vratiotest(y,param1,val1,param2,val2,...)
%
% Description:
%
%   The variance ratio test assesses the null hypothesis that a univariate
%   time series y is a random walk. The null model is
%
%       y(t) = c + y(t-1) + e(t),
%
%   where c is a drift constant and e(t) are uncorrelated innovations with
%   zero mean.
%
%   To strengthen the null model and assume that the e(t) are independent
%   and identically distributed (IID), change the value of the 'IID'
%   parameter (see below) from false to true. When 'IID' is false (the
%   default), the alternative is that the e(t) are correlated. When 'IID'
%   is true, the alternative is that the e(t) are either dependent or not
%   identically distributed (e.g., heteroskedastic).
%
%   Test statistics are based on a ratio of variance estimates of returns
%   r(t) = y(t)-y(t-1) and period q return horizons r(t) + ... + r(t-q+1).
%   Horizons are overlapping to increase the efficiency of the estimator
%   and add power to the test. Under either null, uncorrelated e(t) imply
%   that the period q variance is asymptotically equal to q times the
%   period 1 variance. The variance of the ratio, however, depends on the
%   degree of heteroskedasticity, and so on the null.
%
% Input Arguments:
%
%   y - Vector of time-series data. The last element is the most recent
%       observation. NaNs indicating missing values are removed.
%
% Optional Input Parameter Name/Value Pairs:
%
%   NAME        VALUE
%
%   'period'    Scalar or vector of integers greater than one and less
%               than half the number of observations in y, indicating the
%               period q used to create overlapping return horizons for the
%               variance ratio. The default value is 2.
%
%   'IID'       Scalar or vector of Boolean values indicating whether or
%               not to assume IID innovations. The default value is false.
%
%   'alpha'     Scalar or vector of nominal significance levels for the
%               tests. Values must be greater than zero and less than one.
%               The default value is 0.05.
%
%   Scalar parameter values are expanded to the length of any vector value
%   (the number of tests). Vector values must have equal length. If any
%   value is a row vector, all outputs are row vectors.
%
% Output Arguments:
%
%   h - Vector of Boolean decisions for the tests, with length equal to the
%       number of tests. Values of h equal to 1 indicate rejection of the
%       random-walk null in favor of the alternative. Values of h equal to
%       0 indicate a failure to reject the random-walk null.
%
%   pValue - Vector of p-values of the test statistics, with length equal
%       to the number of tests. Values are standard normal probabilities.
%
%   stat - Vector of test statistics, with length equal to the number of
%       tests. Statistics are asymptotically standard normal.
%
%   cValue - Vector of critical values for the tests, with length equal to
%       the number of tests. Values are for standard normal probabilities.
%
%   ratio - Vector of ratios Var[r(t) + ... + r(t-q+1)]/(q*Var[r(t)]),
%       where r(t) = y(t)-y(t-1). For a random walk, these ratios are
%       asymptotically equal to one. For a mean-reverting series, the
%       ratios are less than one. For a mean-averting series, the ratios
%       are greater than one.
%
% Notes:
%
%   o The input series y is in levels. To convert a return series r to
%     levels, define y(1) and let y = cumsum([y(1) r]).
%
%   o The 'IID' flag is false by default, since the IID assumption is
%     often unreasonable for long-term macroeconomic or financial price
%     series. Rejection of the random-walk null due to heteroskedasticity
%     is usually of little interest in these cases.
%
%   o Rejection of the null due to dependence of the innovations does not
%     imply that the e(t) are correlated. Dependence allows that nonlinear
%     functions of the e(t) are correlated, even when the e(t) are not. For
%     example, it may be that Cov[e(t),e(t-k)] = 0 for all k ~= 0, while
%     Cov[e(t)^2,e(t-k)^2] ~= 0 for some k ~= 0.
%
%   o The test is two-tailed, so the random-walk null is rejected if the
%     test statistic is outside of the critical interval [-cValue,cValue].
%     Each tail outside of the critical interval has probability alpha/2.
%
%   o The test finds the largest integer n such that n*q <= T-1, where q is
%     the period and T is the sample size, and then discards the final
%     (T-1)-n*q observations. To include these final observations, discard
%     the initial (T-1)-n*q observations in y before running the test.
%
%   o When the period q has the default value of 2, the first-order
%     autocorrelation of the returns is asymptotically equal to ratio-1.
%
%   o Cecchetti and Lam [2] show that sequential testing using multiple
%     values of q results in small-sample size distortions beyond those
%     that result from the asymptotic approximation of critical values. 
%
% Example:
%
%   % Test US equity index data for a random walk using various periods q,
%   % with and without the IID assumption:
%
%   load indexdata
%   data = IndexData.US; % Daily close of S&P 500, 04-27-1993 to 07-14-2003
%   y = log(data);
%   plot(diff(y)) % Return series, showing heteroskedasticity
%   q = [2 4 8 2 4 8];
%   isIID = logical([1 1 1 0 0 0]);
%   [h,pValue,stat,cValue,ratio] = vratiotest(y,'period',q,'IID',isIID)
%   rho1 = ratio(1)-1 % First-order autocorrelation of the returns
%
%   % The test fails to reject the random-walk null at the default 5%
%   % significance level, except in the case where 'period' is 8 and 'IID'
%   % is true. The rejection is likely due to the heteroskedasticity.
%
% References:
%
%   [1] Campbell, J. Y., A. W. Lo, and A. C. MacKinlay. "The Econometrics
%       of Financial Markets." Princeton, NJ: Princeton University Press,
%       1997.
%
%   [2] Cecchetti, S. G., and P. S. Lam. "Variance-Ratio Tests: Small-
%       Sample Properties with an Application to International Output
%       Data." Journal of Business and Economic Statistics. Vol. 12, 1994,
%       pp. 177-186.
%
%   [3] Cochrane, J. "How Big is the Random Walk in GNP?" Journal of
%       Political Economy. Vol. 96, 1988, pp. 893-920.
%
%   [4] Faust, J. "When Are Variance Ratio Tests for Serial Dependence
%       Optimal?" Econometrica. Vol. 60, 1992, pp. 1215-1226.
%
%   [5] Lo, A. W., and A. C. MacKinlay. "Stock Market Prices Do Not Follow
%       Random Walks: Evidence from a Simple Specification Test." Review of
%       Financial Studies. Vol. 1, 1988, pp. 41-66.
%
%   [6] Lo, A. W., and A. C. MacKinlay. "The Size and Power of the Variance
%       Ratio Test." Journal of Econometrics. Vol. 40, 1989, pp. 203-238.
%
%   [7] Lo, A. W., and A. C. MacKinlay. "A Non-Random Walk Down Wall St."
%       Princeton, NJ: Princeton University Press, 2001.
%  
% See also ADFTEST, PPTEST, KPSSTEST.

% Copyright 1999-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/05/07 18:18:35 $

% Parse inputs and set defaults:

parseObj = inputParser;
parseObj.addRequired('y',@yCheck);
parseObj.addParamValue('period',2,@periodCheck);
parseObj.addParamValue('IID',false,@IIDCheck);
parseObj.addParamValue('alpha',0.05,@alphaCheck);

parseObj.parse(y,varargin{:});

y = parseObj.Results.y;
period = parseObj.Results.period;
IID = parseObj.Results.IID;
alpha = parseObj.Results.alpha;

% Check parameter values for commensurate lengths, expand scalars, and
% convert all variables to columns:

[numTests,rowOutput,period,IID,alpha] = sizeCheck(period,IID,alpha);
y(isnan(y)) = []; % Remove missing values
numObs = length(y);
y = y(:);

% Check if the period q is too large:

if any(period >= numObs/2)
	error('econ:vratiotest:TooFewObservations',...
          'Number of observations must be \ngreater than twice the period.')
end

% Create the return series:

r = diff(y);
n = floor((numObs-1)./period);
N = n.*period; % Number of non-overlapping period q intervals in r.

% Preallocate output variables:

h = false(numTests,1);
pValue = NaN(numTests,1);
stat = NaN(numTests,1);
cValue = NaN(numTests,1);
ratio = NaN(numTests,1);

% Run the tests:

for i = 1:numTests
    
    testStep = period(i);
    testIID = IID(i);
    testAlpha = alpha(i);
    testN = N(i);
    
    % Estimate the drift constant:
    
    c = (y(testN+1)-y(1))/testN;
    
    % Period 1 estimator of the variance of the returns:
    
    e1 = r(1:testN)-c;
    sse1 = e1'*e1;
    m1 = testN-1;
    var1 = sse1/m1;
    
    % Period q estimator of the variance of the returns:
    
    e2 = y(testStep+1:testN+1)-y(1:testN-testStep+1)-testStep*c;
    sse2 = e2'*e2;
    m2 = testStep*(testN-testStep+1)*(1-testStep/testN);
    var2 = sse2/m2;
    
    % Variance ratio:
    
    testRatio = var2/var1;
    
    % Estimate the asymptotic variance of the variance ratio:
    
    if testIID
        
        ratioVar = 2*(2*testStep-1)*(testStep-1)/(3*testStep);
        
    else % Heteroskedasticity-consistent estimator
        
        summands = zeros(testStep-1,1);
        for k = 1:testStep-1            
            sq1 = e1(k+1:testN).^2;
            sq2 = e1(1:testN-k).^2;
            delta = testN*(sq1'*sq2)/sse1^2;
            sq3 = (1-k/testStep)^2;
            summands(k) = sq3*delta;
        end
        
        ratioVar = 4*sum(summands);
               
    end
    
    % Compute the asymptotically standard normal test statistic:
    
    testStat = sqrt(testN)*(testRatio-1)/sqrt(ratioVar);
    
    % Evaluate the statistic:
    
    testPValue = 2*normcdf(-abs(testStat),0,1); % Two-tailed test
    testH = (testPValue <= testAlpha);
    
    if nargout >= 4
        
        testCValue = norminv(1-testAlpha/2,0,1);
        
    else
        
        testCValue = NaN;
        
    end
    
    % Add the test results to the outputs:
    
    h(i) = testH;
    pValue(i) = testPValue;
    stat(i) = testStat;
    cValue(i) = testCValue;
    ratio(i) = testRatio;
    
end

% Display outputs as row vectors if any parameter value is a row vector:

if rowOutput
    
    h = h';
    pValue = pValue';
    stat = stat';
    cValue = cValue';
    ratio = ratio';
    
end

%-------------------------------------------------------------------------
% Check input y
function OK = yCheck(y)
            
    if isempty(y)
        error('econ:vratiotest:DataUnspecified',...
              'Observed data is empty.')
    elseif ~isnumeric(y)
        error('econ:vratiotest:DataNonNumeric',...
              'Observed data must be numeric.')
    elseif ~isvector(y)
        error('econ:vratiotest:DataIsArray',...
              'Observed data must be a vector.')
    else
        OK = true;
    end

%-------------------------------------------------------------------------
% Check value of 'period' parameter
function OK = periodCheck(period)
    
    if ~isnumeric(period)
        error('econ:vratiotest:PeriodNonNumeric',...
              'Period must be numeric.')
    elseif ~isvector(period)
        error('econ:vratiotest:PeriodIsArray',...
              'Period must be a scalar or a vector.')
    elseif any(mod(period,1) ~= 0) || any(period <= 1)
        error('econ:vratiotest:PeriodNonIntegerOrTooSmall',...
              'Period must be an integer greater than 1.')
    else
        OK = true;
    end

%-------------------------------------------------------------------------
% Check value of 'IID' parameter
function OK = IIDCheck(IID)
    
    if ~islogical(IID)
        error('econ:vratiotest:IIDNonBoolean',...
              'IID flag must be Boolean.')
    elseif ~isvector(IID)
        error('econ:vratiotest:IIDIsArray',...
              'IID flag must be a scalar or a vector.')
    else
        OK = true;
    end

%-------------------------------------------------------------------------
% Check value of 'alpha' parameter
function OK = alphaCheck(alpha)
    
    if ~isnumeric(alpha)
        error('econ:vratiotest:AlphaNonNumeric',...
              'Significance level must be numeric.')
    elseif ~isvector(alpha)
        error('econ:vratiotest:AlphaIsArray',...
              'Significance level must be a scalar or a vector.')
    elseif any(alpha <= 0) || any(alpha >= 1)
        error('econ:vratiotest:AlphaOutOfRange',...
              'Significance levels must be between 0 and 1.')
    else
        OK = true;
    end
     
%-------------------------------------------------------------------------
% Check parameter values for commensurate lengths, expand scalars, and
% convert all variables to columns
function [numTests,rowOutput,varargout] = sizeCheck(varargin)

% Initialize outputs:

numTests = 1;
rowOutput = false;

% Determine vector lengths, number of tests, row output flag:

for i = 1:nargin
    
    paramLength.(inputname(i)) = length(varargin{i});
    numTests = max(numTests,paramLength.(inputname(i)));
    
    if ~isscalar(varargin{i})
        rowOutput = rowOutput || (size(varargin{i},1) == 1);
    end    
    
end

% Check for commensurate vector lengths:

for i = 1:(nargin-1)
    for j = (i+1):nargin        
        if (paramLength.(inputname(i)) > 1) && (paramLength.(inputname(j)) > 1) ...
            && (paramLength.(inputname(i)) ~= paramLength.(inputname(j)))
            error('econ:vratiotest:ParameterSizeMismatch',...
                  'Vectors ''%s'' and ''%s'' must be the same length.',...
                  inputname(i),inputname(j))
        end        
    end
end

% Expand scalars:

for i = 1:nargin
    
    if paramLength.(inputname(i)) == 1
        varargout{i} = varargin{i}(ones(numTests,1));
    else
        varargout{i} = varargin{i}(:);  % Column output
    end
    
end