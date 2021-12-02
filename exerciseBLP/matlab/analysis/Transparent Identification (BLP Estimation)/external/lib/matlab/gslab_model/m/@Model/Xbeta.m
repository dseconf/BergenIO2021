function xbeta = XBeta(obj, varlist, data, param, include_constant, coef_prefix, datavar_suffix, constname)
%
% XBeta computes the sum of rhs variables in varlist and their associated
%   coefficients. This is not used in the main Model class, but is 
%   provided as a utility for implementing subclasses.
%

if nargin<6
    coef_prefix = '';
end
if nargin<7
    datavar_suffix = '';
end
if nargin<8
    constname = 'constant';
end

xbeta = zeros(data.nobs,1);
for name = varlist
    coeffname = [coef_prefix name{:} '_coeff'];
    xbeta = xbeta + param(obj.indices.(coeffname)).*data.var.([name{:} datavar_suffix]);
end
if nargin >= 5 && include_constant
    xbeta = xbeta + param(obj.indices.([coef_prefix constname]));
end

