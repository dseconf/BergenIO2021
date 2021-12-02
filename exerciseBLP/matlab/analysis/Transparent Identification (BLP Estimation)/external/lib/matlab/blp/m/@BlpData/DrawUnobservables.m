function obj = DrawUnobservables(obj, nunobs)
%
% Draw equally-weighted unobservables (no importance sampling).
%
% 
% INPUTS
%     - nunobs: Number of unobservables to draw
%

rng(05292011);
obj.unobs = randn(nunobs, obj.nvars_unobs);
obj.unobs_income = randn(nunobs, 1);
obj.unobs_weight = ones(nunobs, 1);
obj.income = obj.ComputeIncome();

end