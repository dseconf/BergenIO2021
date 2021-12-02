function assertbad(input)
%
% Confirm that evaluating input produces an error 
%

if ~isequal(input(end), ';')
    input = [input ';'];
end

error = false;
try
    evalin('caller', input);
catch
    error = true ;
end
assert(error == true, 'Input did not produce error as expected');

