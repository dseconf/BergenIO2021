function [g, g_model, g_car, beta] = ComputeDistanceVector(obj, data, param, proj_z, beta)
%
% Takes as input a parameter vector and data, including values for all unobservables,
% and returns a g vector as defined in Newey and McFadden 1994
%
%
% INPUTS
%     - data:   BlpData() object
%     - param:  Vector of parameters at which to compute distances
%     - proj_z: Projection matrix for IV
%     - beta:   Vector of mean parameters for computation of error terms (optional)
% 
% OUTPUTS
%     - g:       Real vector of distances
%     - g_model: Real vector of sum of distances for each model
%     - beta:    Vector of mean parameters given inputs
%

[delta, mc] = obj.ComputeModelOutputs(data, param);
log_mc = log(mc);

% Uses IV to get unobservables
y = [delta; log_mc];
x = data.GetArray(obj.demand_varlist);
w = data.GetArray(obj.supply_varlist);
xw = blkdiag(x, w);

demand_iv_var = data.GetArray(obj.demand_iv_varlist);
supply_iv_var = data.GetArray(obj.supply_iv_varlist);
z = blkdiag(demand_iv_var, supply_iv_var);

% Computes mean parameters unless given
if nargin <= 4
    beta = (xw'*proj_z*xw) \ (xw'*proj_z*y);
end

e = y - xw*beta;
g_car = repmat(e, 1, size(z, 2)) .* z;

% Takes group means over each model
g_model = zeros(data.nmodels, length(obj.iv_varnames));
model_levels = data.model_levels;
models = data.GetArray(data.varlist.model);
for i = 1:data.nmodels
    model_obs = [models == model_levels(i); models == model_levels(i)];
    g_model(i, :) = sum(g_car(model_obs, :), 1);
end

g = mean(g_model, 1)';

end