%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCBY.M: Apply a function to an array within the groups defined by a second array.
%   v = funcby(x,g,@fun) is equivalent to Stata commands like
%
%       egen v = sum(x), by(g)
%       egen v = prod(x), by(g) 
%       etc.
%
%   This is just like the Matlab command accumarray, except that it produces a vector
%   of the same length as x and g where all elements corresponding to a given value of g
%   are equal and contain the sum, product, etc. over the relevant elements of x.
%
%   It also differs from both accumarray and the Stata commands by allowing x and g to be arrays,
%   in which case it operates along the first dimension of x. 
%
% INPUTS:
%	x       Array containing values
%   g       Array defining groups (must have same length as x)
%   fun     Function to apply to values in x (if not specified, default is @sum)
%	
% OUTPUTS:
%	v       Vector of group indices
%	
% Created: MG 8/22/08
% Modified:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function v = funcby(x,g,fun)

if nargin<2
    error('funcby() must be called with at least two arguments')
end
if ~isequal(size(x),size(g))
    error('First two inputs to funcby() must have the same dimensions')
end
if nargin==3 && isa(fun,'function_handle')==0
    error('Third input to funcby() must be a function handle such as @sum, @prod, @max, etc.')
end

% renormalize g to satisfy requirements of accumarry()
g = int32(g);
g = g-min(g)+1;

if size(x,2)==1
    if nargin==2 || (nargin==3 & strcmp(func2str(fun),'@sum'))
        v = accumarray(g,x); 
    else
        v = accumarray(g,x,[],fun); 
    end
    v = v(g);
else
    % create a new index array so that each vector along first dimension has unique indices
    dim = size(x);
    gx = g + reshape(repmat([0:(prod(dim(2:end))-1)],dim(1),1),dim).*max(g(:));
    
    if nargin==2 || (nargin==3 & strcmp(func2str(fun),'sum'))
        v = accumarray(gx(:),x(:)); 
    else
        v = accumarray(gx(:),x(:),[],fun);
    end
    v = v(gx);
    v = reshape(v,dim);
end


end

