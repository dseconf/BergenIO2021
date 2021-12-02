function obj = AddIncomeParams(obj, means_file, sd_file)
%
% Add income parameters to BlpData object.
%
% 
% INPUTS
%     - means_file: File containing (in the second column) mean of log-income for each market
%     - sd_file:    File containing standard deviation of log-income (across all markets)
%

means = load(means_file);
obj.const.log_income_mean = means(:, 2);
obj.const.log_income_sd = load(sd_file);

obj.var.log_income_mean = obj.const.log_income_mean(grp2idx(obj.GetArray(obj.varlist.market)));

% Prevents income computation before unobservables are drawn (when initializing object)
if ~isempty(obj.unobs)
    obj.income = obj.ComputeIncome();
end

end