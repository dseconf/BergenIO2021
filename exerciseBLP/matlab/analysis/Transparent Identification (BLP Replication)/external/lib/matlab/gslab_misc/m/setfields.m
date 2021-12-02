%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% SETFIELDS.M: Modify setfield() command to allow setting multiple fields
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = setfields(struct,varargin)

out = struct;

% make sure number of input arguments is even
assert(mod(length(varargin),2)==0,'Error in inputs');

% make substitutions indicated by varargin
for i=1:2:length(varargin)
    out = setfield(out,varargin{i},varargin{i+1});
end


