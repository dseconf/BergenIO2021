function test_assertbad
%
% Unit tests for assertbad function
%

x = 1;
y = 'hello';

% Good cases
assertbad( 'sqrt(y)' )
assertbad( 'z' )

% Bad cases
ok = false;
try
    assertbad( 'sqrt(x)' );
catch
    ok = true;
end
assert(ok);

ok = false;
try
    assertbad( 'y' );
catch
    ok = true;
end
assert(ok);

end