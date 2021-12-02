function obj = ExpandArrayVars(obj)
%
% Expands variables which are double arrays into multiple dataset variables the form 
%   [varname]_array_[ind1]_[ind2]
%
% INPUTS
%
%    - obj: ModelData object. Note that obj.var must not contain any variables which are cell arrays. 
%
% OUTPUTS
%
%    - obj: ModelData object, with all variables which are double arrays [varname] with dimension 
%           X by Y expanded into dataset variables of the form [varname]_array_[1:X]_[1:Y].
%           

varnames = obj.var.Properties.VarNames;
dataout = dataset();

for i = 1:length(varnames)
    assert(~strcmp(class(obj.var.(varnames{i})), 'cell'));
    nrow = size(obj.var.(varnames{i}),2);
    ncol = size(obj.var.(varnames{i}),3);
    if nrow == 1 && ncol == 1
        dataout.(varnames{i}) = obj.var.(varnames{i});
    else
        for r = 1:nrow
            for c = 1:ncol
                arrayname = strcat(varnames{i}, '_array_', num2str(r), '_', num2str(c));
                dataout.(arrayname) = obj.var.(varnames{i})(:,r,c);
            end
        end
    end
end
obj.var = dataout;
end
