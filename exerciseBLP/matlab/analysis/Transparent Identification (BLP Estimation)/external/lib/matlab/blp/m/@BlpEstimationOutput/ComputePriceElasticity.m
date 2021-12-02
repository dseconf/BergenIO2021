function price_elasticity = ComputePriceElasticity(obj, data, param)
%
% Computes elasticity of demand with respect to price
%
%
% INPUTS
%     - data:  BlpData() object
%     - param: Vector of model parameters at which to compute elasticities (optional)
% 
% OUTPUTS
%     - price_elasticity: [# products] x 1 vector of price elasticities
%

if nargin <= 2
    param = obj.param;
end

[~, ~, ~, market_share, indiv_market_share] = obj.model.ComputeModelOutputs(data, param);

% Follows from price utility approximation
jacobian_mu_price = -param(obj.model.indices.alpha_price) ./ data.income;
% Derivative of own share to own price
jacobian_share_price = mean(indiv_market_share .* (1-indiv_market_share) .* ...
    jacobian_mu_price .* repmat(data.unobs_weight', data.nobs, 1), 2);

% Note that we multiply by -1 to give positive price elasticities
price_elasticity = -jacobian_share_price .* data.GetArray(data.varlist.price) ./ market_share;

end