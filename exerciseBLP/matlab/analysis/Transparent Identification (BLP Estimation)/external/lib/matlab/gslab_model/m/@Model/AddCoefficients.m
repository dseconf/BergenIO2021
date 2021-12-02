function [newlist newnames] = AddCoefficients(paramlist, varlist, include_constant, prefix, suffix)
%
% AddCoefficientsToParamlist adds coefficient names and a constant term to 
%   paramlist. This is not used in the main Model class, but is 
%   provided as a utility for implementing subclasses.
%

if nargin<4
    prefix = '';
end
if nargin<5
    suffix = '_coeff';
end

coefflist = cell(1, length(varlist));
for i = 1:length(varlist)
    coefflist{i} = [prefix varlist{i} suffix];
end
if include_constant
    coefflist = [[prefix 'constant'] coefflist];
end

newlist = [coefflist paramlist];
newnames = coefflist;
