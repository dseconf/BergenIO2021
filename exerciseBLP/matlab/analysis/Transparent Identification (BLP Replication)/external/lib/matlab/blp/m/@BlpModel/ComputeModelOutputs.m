function [delta, mc, mu, market_share, indiv_market_share] = ComputeModelOutputs(obj, data, param)
%
% Computes model outputs mean utilities and marginal costs.
%
%
% INPUTS
%     - data:  BlpData() object
%     - param: Vector of parameters at which to compute distances
% 
% OUTPUTS
%     - delta:              [# products] x 1 vector of mean utilities
%     - mc:                 [# products] x 1 vector of marginal costs
%     - mu:                 [# products] x 1 vector of random utilities
%     - market_shares:      [# products] x 1 vector of market shares
%     - indiv_market_share: [# products] x [# individuals] matrix of individual market shares
%

data_cell = data.SplitDataByMarket();
mu_cell = cell(data.nmarkets, 1);
delta_cell = cell(data.nmarkets, 1);
mc_cell = cell(data.nmarkets, 1);
market_share_cell = cell(data.nmarkets, 1);
indiv_market_share_cell = cell(data.nmarkets, 1);

parfor i = 1:data.nmarkets
    data_market = data_cell{i};
    mu_cell{i} = obj.ComputeRandomUtility(data_market, param);
    delta_cell{i} = obj.DeltaContraction(data_market, mu_cell{i});
    [market_share_cell{i}, indiv_market_share_cell{i}] = ...
        obj.ComputeMarketShare(data_market, exp(delta_cell{i}), exp(mu_cell{i}));
    mc_cell{i} = obj.ComputeMarginalCost(data_market, param, market_share_cell{i}, indiv_market_share_cell{i});
end

mu = cell2mat(mu_cell);
delta = cell2mat(delta_cell);
mc = cell2mat(mc_cell);
market_share = cell2mat(market_share_cell);
indiv_market_share = cell2mat(indiv_market_share_cell);

end