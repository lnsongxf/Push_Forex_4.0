function newMatrix = calcMainDerivative( algo,operatMatrix )

s           = size(operatMatrix);
newMatrix   = zeros(s(1),s(2)+1);

for i = 1 : s(1)
    hold off
    algo.actIndex   = operatMatrix(i,1);
    m               = algo.buildVectValues.matrixVal;
    v               = m(:,4);
    c               = csaps(1:length(v),v,.001,1:length(v));
    c1              = csaps(1:length(v),v,.3,1:length(v));
    g               = gradient(c);
    g1              = gradient(c1);
    newMatrix(i,:)  = [operatMatrix(i,:) sign(g(length(g))*g1(length(g1)))];
    plot(v);
    hold on;
    plot(c);
    plot(c1);
end

end

