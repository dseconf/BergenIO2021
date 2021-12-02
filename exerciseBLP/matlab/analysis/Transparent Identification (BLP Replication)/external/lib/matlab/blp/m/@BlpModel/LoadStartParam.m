function obj = LoadStartParam(obj, startparam_file)
%
% Loads starting parameters from file.
%
% 
% INPUTS
%     - startparam_file: File containing starting parameters. The first
%                        column must be a column of parameter names, and the 
%                        second column must be a column of starting parameters.
%                        The first row is assumed to be a header row.
%

file_contents = importdata(startparam_file);
param_names = file_contents.textdata(2:end, 1);
start_param = file_contents.data(:, 1);
relevant_indices = ismember(param_names, obj.paramlist);

obj.default_startparam = start_param(relevant_indices);

end