function test_write_checksum
%
% Unit tests for test_write_checksum function
%

x = ones(10,10);
y = 3;

% Good cases
write_checksum('temp.txt', 'my_function.m', x);
write_checksum('temp.txt', 'my_function.m', x, y);

delete('temp.txt')
