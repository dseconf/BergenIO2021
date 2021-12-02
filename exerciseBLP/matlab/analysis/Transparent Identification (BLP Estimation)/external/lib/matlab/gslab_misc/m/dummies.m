%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DUMMIES.M: Replace each column of a matrix M with columns of dummy variables, one for
%   each value that that column of M takes, or one for each value in a specified input
%   array. Note that this is currently coded with a loop over columns so it is effient 
%   for many rows but not many columns.
%
% INPUTS:
%	M   Matrix where each column is a categorical variable
%   V   Cell array where V{i} gives the possible values to encode for column i of M.
%       Dummies will be created in the same order as V{i}
%	
% OUTPUTS:
%	D   Matrix where each column is replaced with a set of columns of dummy variables
%	
% Created: MG 9/08
% Modified:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function D = dummies(M,V)

if nargin==2 & size(M,2)~=size(V,2)
    error('Input matrix M and cell array V must have the same number of columns')
end

D=[];
for i=1:size(M,2)
    if nargin==2
        if size(V{i},2)~=1
            error('Each element of input cell array V must be a column vector')
        end
        u = V{i};
    else
        u = unique(M(:,i));
    end
    D=[D repmat(M(:,i),1,size(u,1))==repmat(u',size(M,1),1)];
end

