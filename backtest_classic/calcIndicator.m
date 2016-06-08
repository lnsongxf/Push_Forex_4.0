function ind = calcIndicator( params,values )

vect = values.getClosureVect;
c   = csaps(1:length(vect),vect,params.get('coeff_____'));
g   = c.coefs(:,3);
ind = g(end);

end

