function test_parse_name_list
%
% Unit tests for parse_name_list function
%

% Good case

namelist = {'a', 'b', 'c'};
[n, indices] = parse_name_list(namelist);
assert( n==3 );
assert( indices.b == 2 );

% Bad case
opt = 'opt';
assertbad( 'parse_name_list(4)' );
assertbad( 'parse_name_list({4, opt})' );

