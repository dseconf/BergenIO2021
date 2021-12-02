function test_addvar2struct
%
% Unit tests for addvar2struct function
%

% Good case
s.a = [1, 2, 3];
s.b = 'hello';
c = [1, 2; 1, 2];
d = {'a', 'b', 'c'};

s = addvar2struct(s, c, d);
assert( size(s.c, 1) == 2 );
assert( size(s.c, 2) == 2 );
assert( length(s.d) == 3 );

% Bad case
assertbad( 'addvar2struct(c, d)' );

