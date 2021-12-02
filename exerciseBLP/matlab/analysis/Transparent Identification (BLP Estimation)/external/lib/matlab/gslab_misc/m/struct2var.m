%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STRUCT2VAR.M: Define a series of variables from a structure using field names as variable
%   names.
%
% INPUTS:
%	S       Input structure
%
% OUTPUTS:
%	var1    1st variable
%   var2    2nd variable
%   ...     etc.
%	
% Created: MG 5/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function varargout = struct2var(S)

if nargin~=1 || ~isstruct(S)
    error('Input to struct2var must be a structure array')
end

names = fieldnames(S);

for ii = 1:length(names)
    if ~isvarname(names{ii})
        error(['Field name [' names{ii} '] is not a valid variable name'])
    end
    eval(['X = S.' names{ii} ';']);
    assignin('caller',names{ii},X);
end
    




