function test_expand_array
%
% Unit tests for expand_array function
%

% Set up data
x = [1;2;3;4;5];
y = [1 2;3 4;5 6; 7 8; 9 10];

countsx = [1;1;3;2;1];
answerx = [1;2;3;3;3;4;4;5];

countsy = [1;2;1;1;2];
answery = [1 2;3 4;3 4;5 6;7 8;9 10;9 10];

numreps = 10^5;
yrep = repmat(y, numreps, 1);
countsyrep = repmat(countsy, numreps, 1);
answeryrep = repmat(answery, numreps,1 );

% Good cases
assert(isequal(expand_array(x, countsx), answerx));
assert(isequal(expand_array(y, countsy), answery));
assert(isequal(expand_array(yrep, countsyrep), answeryrep));
