function obj = LoadUnobservablesFromEstimate(obj, est)
%
% Load unobservables from BlpEstimationOutput object.
%
% 
% INPUTS
%     - est: A BlpEstimationOutput object from which to load unobservables
%

obj.unobs = est.unobs;
obj.unobs_income = est.unobs_income;
obj.unobs_weight = est.unobs_weight;
obj.income = obj.ComputeIncome();

end