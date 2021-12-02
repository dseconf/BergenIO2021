function obj = LoadUnobservablesFromFile(obj, filename)
%
% Load unobservables stored in a file.
%
% 
% INPUTS
%     - filename: Name for file with unobservables. The first row should be a row
%                 of headers indicating the variables that each column corresponds to.
%

file_contents = importdata(filename);
data = file_contents.data;

% Match unobservable orderings
demand_cols = arrayfun(@(x) (find(ismember(file_contents.colheaders, x))), obj.varlist.unobs_vars);
income_col = ismember(file_contents.colheaders, 'income');
weight_col = ismember(file_contents.colheaders, 'weight');
year_col = ismember(file_contents.colheaders, 'year');
obj.unobs = data(:, demand_cols);
obj.unobs_income = data(:, income_col);
obj.unobs_weight = data(:, weight_col);
obj.unobs_year = data(:, year_col);

obj.income = obj.ComputeIncome();

end