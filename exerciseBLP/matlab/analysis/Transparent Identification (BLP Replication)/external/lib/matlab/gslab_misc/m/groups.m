%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GROUPS.M: Create a vector indexing the groups defined by the columns of a matrix X.
%  This is the equivalent of the Stata command egen v = group(x y z). For example
%  if X is the matrix
%         [1  2
%          1  2
%          1  3
%          2  1
%          2  1
%          2  2]
% then the output will be
%         [1
%          1
%          2
%          3
%          3
%          4]
%
% INPUTS:
%	X   Matrix defining groups
%	
% OUTPUTS:
%	v   Vector of group indices
%	
% Created: MG 8/22/08
% Modified:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function v = groups(X)

[Xsorted index] = sortrows(X);
if isnumeric(Xsorted)
    diff = Xsorted(1:end-1,:)==Xsorted(2:end,:);
elseif iscellstr(Xsorted)
    diff = strcmp(Xsorted(1:end-1,:),Xsorted(2:end,:));
end
v = [1; 1+cumsum(sum(1-diff,2)>0)];
v(index) = v;

end

