function [] = SaveToDiskNative(obj, directory, name)
%
%  Saves an ModelData object to a directory. The var property is saved as a CSV, while the remaining
%      properties are saved as MAT.
%  Note that this method is slower than SaveToDisk, but it allows for some variables to be higher-
%      precision than others, so it can be more time- and space-effective when high precision is
%      required.
%
% INPUTS
%
%    - directory: location of files to be saved
%    - name: name of files to be saved. 
%
% OUTPUTS
%
%    None
%

if ~isempty(obj.groupvar)
    obj.var.groupvar_export = double(obj.groupvar);
end
obj = obj.ExpandArrayVars();

propsonly = obj;
propsonly.var = [];

save(strcat(directory, '/', name, '.mat'), 'propsonly');
export(obj.var, 'File', strcat(directory, '/', name, '.csv'), 'Delimiter', ',');

end