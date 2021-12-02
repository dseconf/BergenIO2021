function [var, iv_varlist] = GenInstruments(obj, group_key, x_var, iv_prefix, exclude_varlists)
%
% Generates BLP instrumental variables by taking group sums of attributes.
%
% 
% INPUTS
%     - group_key:        A cell of variable names to act as group identifiers for group sums
%     - x_var:            A cell of variable names to generate instruments from
%     - iv_prefix:        A string to add to the beginning of output variable names
%     - exclude_varlists: An array of cells of variable names to subtract out of new instruments (optional)
%
% OUTPUTS
%     - var:        A dataset object
%     - iv_varlist: A cell of variable names corresponding to new variables
%

var = obj.var;
group_sums = grpstats(var, group_key, 'sum', 'DataVars', x_var);
iv_var_indices = strncmp(group_sums.Properties.VarNames, 'sum_', 4);
group_sums.Properties.VarNames = strrep(group_sums.Properties.VarNames, 'sum', iv_prefix);
iv_varlist = group_sums.Properties.VarNames(iv_var_indices);
var = join(var, group_sums, 'Keys', group_key, 'RightVars', iv_varlist);

if nargin > 4
    for exclude_varlist = exclude_varlists
        var = subtract_varlist(var, iv_varlist, exclude_varlist{:});
    end
end

var = BlpData.CreateDemeanedVariables(var, iv_varlist);

end

function var = subtract_varlist(var, iv_varlist, exclude_varlist)
    exclude_var = double(var(:, exclude_varlist));
    iv_var = double(var(:, iv_varlist));
    var = replacedata(var, iv_var - exclude_var, iv_varlist);
end