function attribute_elasticity = ComputeAttributeElasticity(obj, data, varname, param, beta)
%
% Computes elasticity of demand with respect to a product attribute.
%
%
% INPUTS
%     - data:  BlpData() object
%     - var:   Variable of data that has associated random and mean coefficients
%     - param: Vector of model parameters at which to compute elasticities (optional)
%     - beta:  Vector of mean coefficient parameters (optional)
% 
% OUTPUTS
%     - attribute_elasticity: [# products] x 1 vector of elasticities to a product attribute
%

if nargin <= 4
    beta = obj.beta;
    if nargin <= 3
        param = obj.param;
    end
end
model = obj.model;
d_var = 0.10;

[delta_old, ~, ~, market_share_old] = model.ComputeModelOutputs(data, param);

data_altered = data;
data_altered.var.(varname) = data_altered.GetArray(varname) + d_var;
delta_altered = delta_old + beta(ismember(model.beta_paramlist, ['demand_', varname])) * d_var;

% Inserts altered mean utility into data to be spliced
data_altered.var.delta_altered = delta_altered;
data_cell = data_altered.SplitDataByMarket();

market_share_cell = cell(data_altered.nmarkets, 1);
for i = 1:data_altered.nmarkets
    data_market = data_cell{i};
    mu = model.ComputeRandomUtility(data_market, param);
    market_share_cell{i} = ...
        model.ComputeMarketShare(data_market, exp(data_market.var.delta_altered), exp(mu));
end
market_share_new = cell2mat(market_share_cell);

market_shares_change = (market_share_new - market_share_old) / d_var;
attribute_elasticity = data.GetArray(varname) .* market_shares_change ./ market_share_old;

end