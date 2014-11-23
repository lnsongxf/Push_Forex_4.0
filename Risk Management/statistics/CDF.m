function [hCDF]=CDF(hPDF)

% hPDF is probability distribution function of variable x
% x binning of CDF is the same of PDF

totNumOper=sum(hPDF(:));
binPercOper=(hPDF*100)/totNumOper;
hCDF=cumsum(binPercOper);

end