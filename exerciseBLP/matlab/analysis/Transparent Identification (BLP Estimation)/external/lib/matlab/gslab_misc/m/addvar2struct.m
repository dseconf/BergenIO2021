%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADDVAR2STRUCT.M: Add to an existing structure from a list of variables using the 
% variable names as field names.
%
% INPUTS:
%   var     existing structure to be added to
%	var1    1st variable
%   var2    2nd variable
%   ...     etc.
%	
% OUTPUTS:
%	S       Output structure created from var with var1, var2, etc.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function S = var2struct(varargin)

S = varargin{1};
if ~isstruct(S) 
    error('First input has to be an existing structure to be added to')
end

for ii=2:size(varargin,2)
    if isempty(inputname(ii))
        error('All inputs to addvar2struct (after the first one) must be valid workspace variables')
    end
    S.(inputname(ii)) = varargin{ii};
end