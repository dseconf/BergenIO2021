function obj = LoadFromDisk(obj, directory, name)
%
% Loads ModelData structure saved using SaveToDisk to an ModelData object. 
%
% INPUTS
%
%    - directory: location of files to be loaded
%    - name: name of files to be loaded. 
%
% OUTPUTS
%
%    - obj: ModelData object loaded from [name].csv and [name].mat, contained in the specified directory.
%

load(strcat(directory, '/', name, '.mat'), 'propsonly')

eval(['obj = ' class(propsonly) '(''File'', strcat(directory,''/'',name, ''.csv''),',...
             '''Delimiter'', '','', ''ReadVarNames'', true);'])
          
obj = obj.CollapseArrayVars();
if sum(~cellfun('isempty', regexp(obj.var.Properties.VarNames, 'groupvar_export'))) >0
    obj.groupvar = obj.var.groupvar_export;
    obj.var.groupvar_export = [];
end

%don't overwrite private or dependent properties
eval(['metadata = ?', class(obj), ';']);
for i = 1:length(properties(class(obj)))
    if strcmp(metadata.PropertyList(i).SetAccess, 'public') && ~(metadata.PropertyList(i).Dependent) ...
        && ~strcmp(metadata.PropertyList(i).Name, 'var') && ~strcmp(metadata.PropertyList(i).Name, 'groupvar')
        property = metadata.PropertyList(i).Name;
        obj.(property) = propsonly.(property);
    end
end
end
