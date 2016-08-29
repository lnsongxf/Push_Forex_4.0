function [xPDFlo,xPDFup,xPDFave,hPDF1,hBin1,hBin1Intgral2,hPDF1Intgral2,indexBin] = PDFcond(values1,values2,n)

% n number of points

valueMax1 = max(values1(:));
valueMin1 = min(values1(:));
stepSize  = (valueMax1-valueMin1)/(n-1);


xPDFlo  = valueMin1:stepSize:valueMax1;
xPDFup  = valueMin1+stepSize:stepSize:valueMax1+stepSize;
xPDFave = (xPDFlo+xPDFup)./2;

l             = length(values1);
indexBin      = zeros(l,1);
hBin1         = zeros(n,1);
hBin1Intgral2 = zeros(n,1);

for i=1:n-1
    
    [index] = find(values1>=xPDFlo(i) & values1<xPDFlo(i+1));
    
    indexBin(index)  = i;
    hBin1(i)         = length(index);
    hBin1Intgral2(i) = sum(values2(index));
    
end

area=trapz(xPDFave,hBin1);
hPDF1=hBin1./area;

area2=trapz(xPDFave,hBin1Intgral2);
hPDF1Intgral2=hBin1Intgral2./area2;

display('test');

end

