function write_checksum(filename, function_name, varargin)
%
% Function to write checksum output to file
%

cs = fopen(filename, 'a');
fprintf(cs, ['*** Checksum for ' function_name ' ***\n']);
fclose(cs);

for X = varargin
    dlmwrite(filename, X, '-append');
    cs = fopen(filename, 'a');
    fprintf(cs, '\n\n');
    fclose(cs);
end

