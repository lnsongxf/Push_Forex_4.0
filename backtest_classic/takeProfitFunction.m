function tp = takeProfitFunction(params)

%lineare
%min(obj.get('maxPercTp_'),obj.get('initPercTp')  + ...
%    abs(obj.get('maxValue__') - obj.get('openValue_'))/obj.get('maxDelta__')*(obj.get('maxPercTp_')-...
%    (obj.get('initPercTp')*sign(obj.get('initPercTp')))))

ftp     = params.get('maxPercTp_');
itp     = params.get('initPercTp');
open    = params.get('openValue_');
maxV    = params.get('maxValue__');
maxd    = params.get('maxDelta__');
nl      = params.get('noLoose___');

dtp     = ftp -itp;

alfa    = (log(dtp+1)*nl/(maxd-nl));
x       = abs(maxV - open);

tp = itp + exp(alfa*(x-nl)/nl) -1;

abc = 76;

end