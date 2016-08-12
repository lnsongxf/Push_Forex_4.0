function [xPDF,hPDF,hBin] =PDFcond(values1,valueMin1,valueMax1,n1,values2,valueMin2,valueMax2,n2)

% valueMax is the max value for the binning
% valueMin is the min value for the binning
% n number of points

xPDF1=valueMin1:(valueMax1-valueMin1)/(n1-1):valueMax1;
xPDF2=valueMin2:(valueMax2-valueMin2)/(n2-1):valueMax2;

[N,C] = hist3([values1,values2],[xPDF,1]);



% [xPDFlat,hPDFlatp,hBinlatp]=PDF(latencyp,xMin,xMax,n);
% 
% 
% 
% 
% hBin=hist(values,xPDF);
% 
% area=trapz(xPDF,hBin);
% hPDF=hBin./area;






end

%
% Just use the definition of conditional probability:
% 
%  [N,C] = hist3([x1,x2],[nbin1,nbin2]);
%  P12 = N./repmat(sum(N,1),size(N,1),1); % Cond. prob. P(x1|x2)
% 
% where P12(i,j) is the conditional probability that x1 is in the i-th
% x1-bin, given that x2 lies in the j-th x2-bin. (The above would produce a
% column of NaNs in any case where no x1,x2 pair occurs for x2 in some
% particular j-th x2-bin, corresponding to an indeterminacy in the
% conditional probability.) C can be used to identify the centers of the
% bin ranges.
% 
%   Of course this only gives you an estimate of the conditional
% probabilities from your particular sample. In fact you can only obtain
% the conditional probabilities for x1 and x2 lying in whatever bins are
% used in 'hist3'.
% 
% Roger Stafford