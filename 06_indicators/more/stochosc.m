function stosc = stochosc(varargin)
%STOCHOSC Stochastic Oscillator.
%
%   STOSC = STOCHOSC(HIGHP, LOWP, CLOSEP) calculates the Fast PercentK
%   (F%K) and Fast PercentD (F%D) from the stock price data, HIGHP
%   (high prices), LOWP (low prices), and CLOSEP (closing prices).  It
%   uses %K period default of 10 periods, %D period default of 3
%   periods, and %D moving average default method of exponential ('e').
%   STOSC is a 2-column matrix whose first column is the F%K values and
%   the second is the F%D values.
%
%   STOSC = STOCHOSC([HIGHP  LOWP  CLOSEP]) is similar to above
%   except the input arguments being a 3-column matrix of high (HIGHP),
%   low (LOWP, and closing prices (CLOSEP), in that order.  The default
%   %K period used is also 10 periods, %D period default of 3 periods,
%   and %D moving average default method of exponential ('e').
%
%   STOSC = STOCHOSC(HIGHP, LOWP, CLOSEP, KPERIODS, DPERIODS, DMAMETHOD)
%   calculates the Fast PercentK (F%K) and Fast PercentD (F%D) from the
%   stock price data, HIGHP (high prices), LOWP (low prices), and CLOSEP
%   (closing prices).  The %K period is manually set through KPERIODS.
%   The %D period is manually set through DPERIODS.  And, %D moving
%   average method is specified in DMAMETHOD.
%
%   STOSC= STOCHOSC([HIGHP  LOWP  CLOSEP], KPERIODS, DPERIODS, DMAMETHOD)
%   is similar to above except the input arguments being a 3-column
%   matrix of high (HIGHP), low (LOWP, and closing prices (CLOSEP), in
%   that order.  The %K period is manually set through KPERIODS.  The
%   %D period is manually set through DPERIODS.  And, %D moving average
%   method is specified in DMAMETHOD.
%
%   Valid moving average methods for %D are Exponential ('e') and
%   Triangular ('t').  Please refer to the help for TSMOVAVG for
%   explanations on those methods.
%
%   Example:   load disney.mat
%              dis_StochOsc = stochosc(dis_HIGH, dis_LOW, dis_CLOSE);
%              plot(dis_StochOsc);
%
%   See also FPCTKD, SPCTKD.

%   Reference: Achelis, Steven B., Technical Analysis From A To Z,
%              Second Printing, McGraw-Hill, 1995, pg. 268-271

%   Copyright 1995-2011 The MathWorks, Inc.

% Check input arguments & extract them, if they are valid.
switch nargin
   case 1   % stochosc([HIGHP  LOWP  CLOSEP])
      if size(varargin{1}, 2) ~= 3
         error(message('finance:ftseries:ftseries_stochosc:HIGH_LOW_CLOSERequired'));
      end
      highp    = varargin{1}(:, 1);
      lowp     = varargin{1}(:, 2);
      closep   = varargin{1}(:, 3);
      kperiods = 10;
      dperiods  = 3;
      dmamethod = 'e';
   case 2   % stochosc([HIGHP  LOWP  CLOSEP], KPERIODS)
      if size(varargin{1}, 2) ~= 3
         error(message('finance:ftseries:ftseries_stochosc:HIGH_LOW_CLOSERequired'));
      end
      highp     = varargin{1}(:, 1);
      lowp      = varargin{1}(:, 2);
      closep    = varargin{1}(:, 3);
      kperiods  = varargin{2};
      if numel(kperiods) ~= 1 || mod(kperiods,1) ~= 0
         error(message('finance:ftseries:ftseries_stochosc:KPERIODSMustBeScalar'));
      elseif isempty(kperiods)
         kperiods = 10;
      end
      dperiods  = 3;
      dmamethod = 'e';
   case 3   % Two possibilities of input syntaxes.
      switch size(varargin{1}, 2)
         case 1   % stochosc(HIGHP, LOWP, CLOSEP)
            highp     = varargin{1}(:);
            lowp      = varargin{2}(:);
            closep    = varargin{3}(:);
            if (size(highp, 1) ~= size(lowp, 1)) || ...
                  (size(lowp, 1) ~= size(closep, 1))
               error(message('finance:ftseries:ftseries_stochosc:LengthOfInputsMustAgree'));
            end
            kperiods  = 10;
            dperiods  = 3;
            dmamethod = 'e';
         case 3   % stochosc([HIGHP  LOWP  CLOSEP], KPERIODS, DPERIODS)
            highp     = varargin{1}(:, 1);
            lowp      = varargin{1}(:, 2);
            closep    = varargin{1}(:, 3);
            kperiods  = varargin{2};
            dperiods  = varargin{3};
            if numel(kperiods) ~= 1 || mod(kperiods,1) ~= 0
               error(message('finance:ftseries:ftseries_stochosc:KPERIODSMustBeScalar'));
            elseif isempty(kperiods)
               kperiods = 10;
            end
            if numel(dperiods) ~= 1 || mod(dperiods,1) ~= 0
               error(message('finance:ftseries:ftseries_stochosc:DPERIODSMustBeScalar'));
            elseif isempty(dperiods)
               dperiods = 3;
            end
            dmamethod = 'e';
         otherwise
            error(message('finance:ftseries:ftseries_stochosc:FirstArgMustBe1or3ColumnMatrix'));
      end
   case 4   % Two possibilities of input syntaxes.
      switch size(varargin{1}, 2)
         case 1  % stochosc(HIGHP, LOWP, CLOSEP, KPERIODS)
            highp     = varargin{1}(:);
            lowp      = varargin{2}(:);
            closep    = varargin{3}(:);
            kperiods  = varargin{4};
            if (size(highp, 1) ~= size(lowp, 1)) || ...
                  (size(lowp, 1) ~= size(closep, 1))
               error(message('finance:ftseries:ftseries_stochosc:LengthOfInputsMustAgree'));
            end
            if numel(kperiods) ~= 1 || mod(kperiods,1) ~= 0
               error(message('finance:ftseries:ftseries_stochosc:KPERIODSMustBeScalar'));
            elseif isempty(kperiods)
               kperiods = 10;
            end
            dperiods  = 3;
            dmamethod = 'e';
         case 3   % stochosc([HIGHP  LOWP  CLOSEP], KPERIODS, DPERIODS, DMAMETHOD)
            highp     = varargin{1}(:, 1);
            lowp      = varargin{1}(:, 2);
            closep    = varargin{1}(:, 3);
            kperiods  = varargin{2};
            dperiods  = varargin{3};
            dmamethod = varargin{4};
            if numel(kperiods) ~= 1 || mod(kperiods,1) ~= 0
               error(message('finance:ftseries:ftseries_stochosc:KPERIODSMustBeScalar'));
            elseif isempty(kperiods)
               kperiods = 10;
            end
            if numel(dperiods) ~= 1 || mod(dperiods,1) ~= 0
               error(message('finance:ftseries:ftseries_stochosc:DPERIODSMustBeScalar'));
            elseif isempty(dperiods)
               dperiods = 3;
            end
            if isempty(dmamethod)
               dmamethod = 'e';
            elseif ~ischar(dmamethod)
               error(message('finance:ftseries:ftseries_stochosc:InvalidMethod'));
            end
         otherwise
            error(message('finance:ftseries:ftseries_stochosc:FirstArgMustBe1or3ColumnMatrix'));
      end
   case 5   % stochosc(HIGHP, LOWP, CLOSEP, KPERIODS, DPERIODS)
      highp     = varargin{1}(:);
      lowp      = varargin{2}(:);
      closep    = varargin{3}(:);
      kperiods  = varargin{4};
      dperiods  = varargin{5};
      if (size(highp, 1) ~= size(lowp, 1)) || ...
            (size(lowp, 1) ~= size(closep, 1))
         error(message('finance:ftseries:ftseries_stochosc:LengthOfInputsMustAgree'));
      end
      if numel(kperiods) ~= 1 || mod(kperiods,1) ~= 0
         error(message('finance:ftseries:ftseries_stochosc:KPERIODSMustBeScalar'));
      elseif isempty(kperiods)
         kperiods = 10;
      end
      if numel(dperiods) ~= 1 || mod(dperiods,1) ~= 0
         error(message('finance:ftseries:ftseries_stochosc:DPERIODSMustBeScalar'));
      elseif isempty(dperiods)
         dperiods = 10;
      end
      dmamethod = 'e';
   case 6   % stochosc(HIGHP, LOWP, CLOSEP, KPERIODS, DPERIODS, DMAMETHOD)
      highp     = varargin{1}(:);
      lowp      = varargin{2}(:);
      closep    = varargin{3}(:);
      kperiods  = varargin{4};
      dperiods  = varargin{5};
      dmamethod = varargin{6};
      if (size(highp, 1) ~= size(lowp, 1)) || ...
            (size(lowp, 1) ~= size(closep, 1))
         error(message('finance:ftseries:ftseries_stochosc:LengthOfInputsMustAgree'));
      end
      if numel(kperiods) ~= 1 || mod(kperiods,1) ~= 0
         error(message('finance:ftseries:ftseries_stochosc:KPERIODSMustBeScalar'));
      elseif isempty(kperiods)
         kperiods = 10;
      end
      if numel(dperiods) ~= 1 || mod(dperiods,1) ~= 0
         error(message('finance:ftseries:ftseries_stochosc:DPERIODSMustBeScalar'));
      elseif isempty(dperiods)
         dperiods = 10;
      end
      if isempty(dmamethod)
         dmamethod = 'e';
      elseif ~ischar(dmamethod)
         error(message('finance:ftseries:ftseries_stochosc:InvalidMethod'));
      end
   otherwise
      error(message('finance:ftseries:ftseries_stochosc:InvalidNumberOfInputArguments'));
end

% Check for data suffiency.
if (length(highp) < kperiods) || (length(highp) < dperiods)
   error(message('finance:ftseries:ftseries_stochosc:KPERIODS_DPERIODSTooLarge'));
end

% Calculate the PercentK (%K).
pctk        = nan(size(closep));
llv         = llow(lowp, kperiods);
hhv         = hhigh(highp, kperiods);
nzero       = find((hhv-llv) ~= 0);
pctk(nzero) = ((closep(nzero)-llv(nzero))./(hhv(nzero)-llv(nzero))) * 100;

% Calculate the PercentD (%D).
pctd               = NaN*ones(size(closep));

try
   pctd(~isnan(pctk)) = tsmovavg(pctk(~isnan(pctk)), dmamethod, dperiods, 1);

catch E
   E.throw
end

% Form the output matrix.
stosc = [pctk pctd];


% [EOF]
