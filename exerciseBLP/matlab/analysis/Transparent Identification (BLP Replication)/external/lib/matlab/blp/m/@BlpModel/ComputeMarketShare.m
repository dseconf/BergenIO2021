function [market_share, indiv_market_share] = ComputeMarketShare(~, data, expdelta, expmu)
%
% Computes market shares implied by input utility (delta and mu)
%
% 
% INPUTS
%     - data:  BlpData() object
%     - delta: [# products] x 1 vector of mean utility
%     - mu:    [# products] x [# individuals] matrix of random utility
%
% OUTPUTS
%     - market_share:       [# products] x 1 vector of market shares
%     - indiv_market_share: [# products] x [# individuals] vector of individual market shares 
% 

unobs_weight = repmat(data.unobs_weight', data.nobs, 1);

% Conditional market shares
num = repmat(expdelta, 1, data.nunobs) .* expmu;
denom = 1 + sum(num, 1);

indiv_market_share = num ./ repmat(denom, size(num, 1), 1);

market_share = mean(indiv_market_share .* unobs_weight, 2);

end