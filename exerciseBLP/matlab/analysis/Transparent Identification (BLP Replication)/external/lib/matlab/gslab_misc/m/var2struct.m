%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VAR2STRUCT.M: Create a structure from a list of variables using the variable names as field
%   names.
%
% INPUTS:
%	var1    1st variable
%   var2    2nd variable
%   ...     etc.
%	
% OUTPUTS:
%	S       Output structure
%
% Created: MG 9/08
% Modified:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function S = var2struct(varargin)

S=struct;
for ii=1:size(varargin,2)
    if isempty(inputname(ii))
        error('All inputs to var2struct must be valid workspace variables')
    end
    S.(inputname(ii)) = varargin{ii};
end





