function [delta, niter] = DeltaContraction(obj, data, mu)
%
% Solves for delta using BLP (1995) contraction mapping
%
%
% INPUTS
%     - data: BlpData() object
%     - mu:   [# products] x [# individuals] matrix of random utility
% 
% OUTPUTS
%     - delta: [# products] x 1 vector of mean utilities
%     - niter: Number of iterations needed
%

% Initiates delta using logit estimate for first iteration
observed_shares = data.GetArray(data.varlist.observed_share);
expdelta_0 = exp(data.GetArray(data.varlist.logit_depvar));
expmu = exp(mu);
delta_tol = obj.delta_tol;

% Contraction mapping to solve for delta (derived from BLP (1999), struc-inst-steve2.arc)
i = 0;
delta_dist_max = delta_tol * 10;
while (delta_dist_max > delta_tol)
    [market_shares, ~] = obj.ComputeMarketShare(data, expdelta_0, expmu);
    delta_dist = observed_shares ./ market_shares;
    expdelta = expdelta_0 .* delta_dist;
    delta_dist_max = max(abs(1 ./ delta_dist - 1));
    expdelta_0 = expdelta;
    i = i + 1;
end

delta = log(expdelta);
niter = i;

end