function test_copyproperties
%
% Unit tests for copyproperties function
%

% set up objects
x = TestClass;
x.property4 = 2;

y = TestClass;
assert(y.property4 == 1);

% copy properties of x to y
yx = copyproperties(y, x);
assert(yx.property4 == 2);

yx = copyproperties(y, x, 'property4');
assert(yx.property4 == 1);

% called from within TestClass
y = TestClass(x);
assert(y.property4 == 2);
