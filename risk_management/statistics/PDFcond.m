function [xPDF,hPDF1,hBin1,hBin1Intgral2,hPDF1Intgral2,indexBin] = PDFcond(values1,values2,n)

% n number of points

valueMax1 = max(values1(:));
valueMin1 = min(values1(:));

xPDF = valueMin1:(valueMax1-valueMin1)/(n-1):valueMax1;

l             = length(values1);
indexBin      = zeros(l,1);
hBin1         = zeros(n,1);
hBin1Intgral2 = zeros(n,1);

for i=1:n-1
    
    [index] = find(values1>=xPDF(i) & values1<xPDF(i+1));
    
    indexBin(index)  = i;
    hBin1(i)         = length(index);
    hBin1Intgral2(i) = sum(values2(index));
    
end

area=trapz(xPDF,hBin1);
hPDF1=hBin1./area;

area2=trapz(xPDF,hBin1Intgral2);
hPDF1Intgral2=hBin1Intgral2./area2;

display('test');

end

