function test_sortby
%
% Unit tests for sortby function
%

% Set up data
vec = [5; 1; 3];
array = [1 2; 2 3; 3 4];
answer = [2 3;3 4;1 2];
groupsanswer = [1;3;5];

% Good cases
[ans grp] = sortby(array, vec);
assert(isequal(ans, answer));
assert(isequal(grp, groupsanswer));

