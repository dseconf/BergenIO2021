%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GET_CONDITIONAL_SENSITIVITY
% 
% Takes as input:
% - Sensitivity matrix lambda (PXM)
% - VCov of parameters (PXP)
% - VCov of moments (MXM)
% - index of parameters (1XK where K<=P) 
%
% Returns as output: 
% - Conditional sensitivity (KXM) for the subset of K parameters
% - Conditional sufficiency (KX1) for the subset of K parameters
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [CondLambda, CondLambdaTilde, CondDelta] = get_conditional_sensitivity(Lambda, param_vcov, moment_vcov, param_indices)    
    Sigma = build_sigma(Lambda, param_vcov, moment_vcov);

    param_excl_indices = 1:size(param_vcov, 1);
    param_excl_indices(param_indices) = [];
    mom_indices = (1:size(moment_vcov, 1)) + size(param_vcov, 1);
    param_inc_mom_indices = [param_indices mom_indices];
    
    % Construct conditional covariance matrix (See /docs/conditional_sensitivity.lyx for notation)
    Sigma_11 = Sigma(param_inc_mom_indices, param_inc_mom_indices);
    Sigma_12 = Sigma(param_inc_mom_indices, param_excl_indices);
    Sigma_22 = Sigma(param_excl_indices, param_excl_indices);
    CondSigma = Sigma_11 - Sigma_12 / Sigma_22 * Sigma_12';

    param_len = length(param_indices);
    CondSigma_gg = CondSigma(param_len+1:end, param_len+1:end);
    CondSigma_tg = CondSigma(1:param_len, param_len+1:end);
    CondSigma_tt = CondSigma(1:param_len, 1:param_len);
    CondLambda = CondSigma_tg / CondSigma_gg;
    
    cond_se_param = sqrt(diag(CondSigma_tt));
    cond_se_mom = sqrt(diag(CondSigma_gg));
    CondLambdaTilde = get_standardized_sensitivity(CondLambda, cond_se_param, cond_se_mom);

    CondDelta = get_sufficiency(CondLambda, cond_se_param, CondSigma_gg);
end