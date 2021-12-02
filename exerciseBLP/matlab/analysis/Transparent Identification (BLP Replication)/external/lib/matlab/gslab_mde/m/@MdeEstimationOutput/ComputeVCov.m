function vcov = ComputeVCov(gjacobian, wmatrix, Omega, nobs)
% See Newey and McFadden 1994 for notation and expressions
%
% INPUTS
%
%    - gjacobian: Jacobian of g distance vector at estimated parameters.
%    - wmatrix: Weight matrix.
%    - Omega: vcov of data
%
% OUTPUTS
%    - vcov: Variance-covariance matrix.
%

G = gjacobian;  % Jacobian of g distance vector
W = wmatrix;    % Jacobian of active constraints

A = (G'*W*G)^(-1);

vcov = A*G'*W*Omega*W*G*A / nobs;

end