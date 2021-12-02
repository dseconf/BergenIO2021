%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GET_SUFFICIENCY
% 
% Takes as input:
% - Sensitivity matrix lambda (PXM)
% - SEs of parameters (PX1)
% - VCov of moments (MXM)
%
% Optional: 
% - index of moments (1XK where K<=M) 
%
% Returns as output: 
% - Sufficiency (PX1) for the subset of K moments defined in the index for each parameter. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Delta = get_sufficiency(Lambda, param_se, moment_vcov, moment_indices)
    if nargin == 3
        moment_indices = 1:size(moment_vcov, 1);
    end
    Sigma_tg = Lambda * moment_vcov;
    Sigma_tg = Sigma_tg(:, moment_indices);
    moment_vcov = moment_vcov(moment_indices, moment_indices);
    Lambda = Sigma_tg / moment_vcov;
    Delta = diag((Lambda * moment_vcov * Lambda')) ./ (param_se.^2);
end
