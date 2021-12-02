function bool = IsValidParameterVector(obj, param)
%
% IsValidParamterVector determines whether a parameter vector is valid for
%   a given Model object.
%

bool = isequal( size(param), [obj.nparam, 1] );

