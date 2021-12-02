function test_parse_option_list
%
% Unit tests for parse_option_list function
%

% Good cases
parse_option_list('opt1',1);

options = parse_option_list('opt1',4,'opt2','blue');
assert( options.opt1==4);
assert( isequal(options.opt2, 'blue') );

newoptions = parse_option_list(options);
assert( isequal(options, newoptions) );

% Bad cases
opt1 = 'opt1';
assertbad( 'parse_option_list(4)' );
assertbad( 'parse_option_list(4, opt1)' );
assertbad( 'parse_option_list(opt1, 4, 5)' );
