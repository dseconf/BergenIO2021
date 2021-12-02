function [data_out, r2] = RemoveCollinearity(data_in, r2_tol)
%
% Removes collinearity from matrix, subject to provided R^2 tolerance.
%
% 
% INPUTS
%     - data_in: A matrix from which to remove collinear columns
%     - r2_tol:  Tolerance for maximum R^2 from regression of one column on others
%
% OUTPUTS
%     - data_out: Output matrix with collinear columns removed
%     - r2:       R^2 from regression of one column on preceding kept columns
%

assert(r2_tol > 0 & r2_tol < 1);

k = size(data_in, 2);
r2 = ones(k, 1);
r2(1) = 0;

for i = 2:k
    candidate_col = data_in(:, i);
    current_out = data_in(:, r2 <= r2_tol);
    
    % Get R^2
    beta = regress(candidate_col, current_out);
    error = candidate_col - current_out * beta;
    candidate_col_dist = candidate_col - mean(candidate_col);
    r2(i) = 1 - (error' * error) / (candidate_col_dist' * candidate_col_dist);
end

data_out = data_in(:, r2 <= r2_tol);

end