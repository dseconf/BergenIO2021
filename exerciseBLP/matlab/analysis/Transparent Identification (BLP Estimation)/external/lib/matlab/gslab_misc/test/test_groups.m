function test_groups
%
% Unit tests for groups function
%

% Set up data
vec = [1;-1;-1;3;1;5];
array = [1 2; -1 0; -1 0; 3 4; 1 2; 5 6];
strvec = {'a';'b';'b';'c';'a';'d'};
strarray = {'a' 'b';'b' 'c';'b' 'c';'c' 'd';'a' 'b';'d' 'e'};

answer = [2;1;1;3;2;4];
stranswer = [1;2;2;3;1;4];

% Good cases
assert(isequal(groups(vec), answer));
assert(isequal(groups(array), answer));
assert(isequal(groups(strvec), stranswer));
assert(isequal(groups(strarray), stranswer));