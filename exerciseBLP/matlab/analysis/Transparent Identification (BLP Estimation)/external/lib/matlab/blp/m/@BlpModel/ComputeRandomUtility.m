function mu = ComputeRandomUtility(obj, data, param)
%
% Computes random component of utility (mu) for given parameter
%
%
% INPUTS
%     - data:  BlpData() object
%     - param: Vector of parameters at which to compute distances
% 
% OUTPUTS
%     - mu: [# products] x [# individuals] matrix of random utility
%

price = data.GetArray(data.varlist.price);
alpha = param(obj.indices.alpha_price);

price_utility = -(alpha * repmat(price, 1, data.nunobs)) ./ data.income;    % This is an approximation - see notes for details

sigma_indiv = repmat(param(obj.sigma_param_indices)', data.nunobs, 1);
unobs_preference = sigma_indiv .* data.unobs;    % [# individuals] x [# product attributes] matrix of consumer preferences
x = data.GetArray(obj.demand_varlist);    % [# products] x [# product attributes] matrix of product attributes
random_attribute_utility = x * unobs_preference';

mu = price_utility + random_attribute_utility;

end