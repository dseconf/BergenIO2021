function [] = SaveToDisk(obj, directory, name, precision)
%
%  Saves an ModelData object to a directory. The var property is saved as a CSV, while the remaining
%      properties are saved as MAT.
%
% INPUTS
%
%    - directory: location of files to be saved
%    - name: name of files to be saved
%    - precision: number of decimal places to store for all inputs 
%
% OUTPUTS
%
%    None
%

if nargin < 4
    precision = 4;
end

if ~isempty(obj.groupvar)
    obj.var.groupvar_export = double(obj.groupvar);
end
obj = obj.ExpandArrayVars();

propsonly = obj;
propsonly.var = [];
save(strcat(directory, '/', name, '.mat'), 'propsonly');

fid = fopen(strcat(directory, '/', name, '.csv'), 'w');
for i = 1:obj.nvars
    varname = obj.var.Properties.VarNames(i);
    fprintf(fid, '%s,', varname{:});
end
fprintf(fid, '\n');
fclose(fid);

dlmwrite_fast(strcat(directory, '/', name, '.csv'), double(obj.var), 'delimiter', ',',...
              'mode', 'a', 'precision', precision);

end

    
