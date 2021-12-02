%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GET_TRANSFORM_SENSITIVITY
% 
% Takes as input:
% - Sensitivity matrix lambda (PXM)
% - Linear transformation to apply to moments (KXM)
% - VCov of parameters (PXP)
% - VCov of moments (MXM)
%
% Returns as output: 
% - Sensitivity to transformed moments (PXK) 
% - Standardized sensitivity to transformed moments (PXK)  
% - Sufficiency to transformed moments (PX1)
% - VCov of transformed moments (KXK)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ TransLambda, TransLambdaTilde, TransDelta, TransVcov ] = ...
get_transform_sensitivity(Lambda, transform, param_vcov, moment_vcov)
    [~, Sigma_tt, Sigma_tg, Sigma_gg] = build_sigma(Lambda, param_vcov, moment_vcov);
    TransLambda = Sigma_tg * transform' / (transform * Sigma_gg * transform');

    se_param = sqrt(diag(Sigma_tt));
    TransVcov = transform * Sigma_gg * transform';
    se_trans = sqrt(diag(TransVcov));
    TransLambdaTilde = get_standardized_sensitivity(TransLambda, se_param, se_trans);

    TransDelta = get_sufficiency(TransLambda, se_param, TransVcov);
end