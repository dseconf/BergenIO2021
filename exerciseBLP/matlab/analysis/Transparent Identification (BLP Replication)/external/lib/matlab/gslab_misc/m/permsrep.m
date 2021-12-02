%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PERMSREP.M: Produce a matrix whose rows are all possible permutations with repetition from
%   input vector v of length k. A variant of the function perms which does not allow repetition.
%
% INPUTS:
%	v       Vector containing input values
%   k       Length of output vectors of permutations
%	
% OUTPUTS:
%	P       Matrix where each row is a permutation of length k
%
% Created: MG 8/22/08
% Modified:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function P = permsrep(v,k)

if size(v,1)~=1
    error('First input to permsrep() must be a row vector')
end
if size(k,1)~=1 | size(k,2)~=1
    error('Second input to permsrep() must be a scalar')
end

n = size(v,2);
P = zeros(n^k,k);
for ii = 1:k
    P(:,ii) = reshape(repmat(v,n^(k-ii),n^(ii-1)),n^k,1);
end


