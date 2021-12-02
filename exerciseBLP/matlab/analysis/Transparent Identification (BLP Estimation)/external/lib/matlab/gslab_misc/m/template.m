%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ENUMERATE.M: Enumerate possible vectors of incumbent choices
%
% Created: MG 8/25/08
% Modified:
%
% INPUTS:
%   choices     row vector of possible choices
%   maxinc      maximum number of incumbent firms possible
%   types       cell array of possible incumbent choice variables (e.g. # choosing 1, # choosing 0)
%	
% OUTPUTS:
%   M           matrix where each row is a possible vector of incumbent choice variables, ordered
%               in the same way as input vector types
%	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function M = enumerate(choices,maxinc,types)

perm = permsrep([-1 choices],maxinc);
M = zeros((nchoose+1)^maxinc,size(types,2));
for ii = 1:size(types,2)
    if strcmp(types{ii},'inc_choose0')
        M(:,ii) = sum(perm==0,2);
    elseif strcmp(types{ii},'inc_choose1')
        M(:,ii) = sum(perm==1,2);
    elseif strcmp(types{ii},'inc_count')
        M(:,ii) = sum(perm~=-1,2);
    end
end
M = unique(M,'rows')

