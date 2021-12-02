function mc = ComputeMarginalCost(obj, data, param, market_share, indiv_market_share)
%
% Computes marginal costs
%
% 
% INPUTS
%     - data:               BlpData() object
%     - param:              Vector of parameters
%     - market_share:       [# products] x 1 vector of market shares
%     - indiv_market_share: [# products] x [# individuals] vector of individual market shares 
% 
% OUTPUTS
%     - mc: [# products] x 1 vector of marginal costs
%

price = data.GetArray(data.varlist.price);
firm_vec = data.GetArray(data.varlist.firm);
unobs_weight = data.unobs_weight;

% Computes markups
% First creates the diagonal terms
jacobian_mu_price = -param(obj.indices.alpha_price) ./ data.income;    % Follows from price utility approximation
Delta_diag = mean(indiv_market_share .* (1-indiv_market_share) .* ...
    jacobian_mu_price .* repmat(unobs_weight', data.nobs, 1), 2);

jacobian_share_price = diag(Delta_diag);

% Now fills cross-product of Jacobian of market share to price
nobs = length(firm_vec);
[j_vec, r_vec] = meshgrid(1:nobs, 1:nobs);
pairs = [j_vec(:), r_vec(:)];
same_firm = (firm_vec(j_vec) == firm_vec(r_vec));
not_duplicate = (r_vec > j_vec);
pairs = pairs(same_firm & not_duplicate, :);
for pair = pairs'
    j = pair(1);
    r = pair(2);
    jacobian_market_share_price_pair = -indiv_market_share(j, :) .* indiv_market_share(r, :);
    % Definition for jacobian_mu_price implies that Delta is symmetric
    jacobian_share_price_pair = mean(jacobian_market_share_price_pair .* jacobian_mu_price(r, :) .* unobs_weight', 2);
    jacobian_share_price(j, r) = jacobian_share_price_pair;
    jacobian_share_price(r, j) = jacobian_share_price_pair;
end

markup = -jacobian_share_price \ market_share;

% Calculates marginal costs
mc = price - markup;
mc(mc <= 0) = 0.001;    % if marginal cost < 0, replace with 1 dollar as in Petrin (2002)

end