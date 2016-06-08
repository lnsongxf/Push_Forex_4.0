function hhv = hhigh(data, nperiods, dim)
%HHIGH Highest high within the past N periods.
%
%   HHV = HHIGH(DATA) generates a vector of highest high values 
%   the past 14 periods from the matrix/vector DATA.  
%
%   HHV = HHIGH(DATA, NPERIODS, DIM) generates a vector of highest 
%   high values the past NPERIODS periods.  DIM indicates the direction
%   which the highest high is to be searched.  If you input '[]' for
%   NPERIODS, the default is 14.
%
%   Example:   load disney.mat
%              dis_HHigh = hhigh(dis_HIGH);
%              plot(dis_HHigh);
%
%   See also LLOW.

%   Copyright 1995-2005 The MathWorks, Inc.

% Check input arguments.
switch nargin
case 1
    nperiods = 14;
    dim = 1;
case 2
    if prod(size(nperiods)) ~= 1 | mod(nperiods,1) ~= 0
        error(message('finance:ftseries:ftseries_hhigh:NPERIODSMustBeScalar'));
    end
    dim = 1;
case 3
    if isempty(nperiods)
        nperiods = 14;
    end
    if prod(size(nperiods)) ~= 1 | mod(nperiods,1) ~= 0
        error(message('finance:ftseries:ftseries_hhigh:NPERIODSMustBeScalar'));
    end
otherwise
    error(message('finance:ftseries:ftseries_hhigh:InvalidNumOfArguments'));
end

% If the input is a vector, make sure it's a column vector.
tflag = 0;
if size(data, 1) == 1
    data = data(:);
    tflag = 1;
end

% Make sure that number of period does not exceed number of observations.
if nperiods > size(data, dim)
    error(message('finance:ftseries:ftseries_hhigh:NPERIODSTooLarge'));
end

% Generate the highest high vector.
if (nperiods > 0) & (nperiods ~= 0)
    hhv = zeros(size(data));
    switch dim
    case 1   % Find highest high column-wise.
        for didx = 1:size(data, 1)
            if didx < nperiods
                hhv(didx, :) = max(data(1:nperiods, :), [], 1);
            else
                hhv(didx, :) = max(data(didx-nperiods+1:didx, :), [], 1);
            end
        end
    case 2
        for didx = 1:size(data, 2)
            if didx < nperiods
                hhv(:, didx) = max(data(:, 1:nperiods), [], 2);
            else
                hhv(:, didx) = max(data(:, didx-nperiods+1:didx), [], 2);
            end
        end
    otherwise
        error(message('finance:ftseries:ftseries_hhigh:InvalidDimension'));
    end
elseif nperiods < 0
    error(message('finance:ftseries:ftseries_hhigh:NPERIODSMustBePosScalar'));
else
    hhv = data;
end

% If the output is a vector, transpose it, if needed.
if tflag
    hhv = hhv';
end

% [EOF]
