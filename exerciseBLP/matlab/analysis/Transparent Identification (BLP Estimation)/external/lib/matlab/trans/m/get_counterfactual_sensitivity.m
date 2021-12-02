%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GET_COUNTERFACTUAL_SENSITIVITY
% 
% Takes as input:
% - Sensitivity matrix lambda (PXK)
% - Jacobian of transformation to apply to parameters (CXP)
%
% Optionally takes: 
% - VCov of parameters (PXP) 
% - VCov of moments (KXK) 
%
% Returns as output: 
% - Sensitivity of counterfactual to moments (CXK) 
%
% Optionally returns if VCovs are provided:
% - Standardized sensitivity of counterfactual to moments via delta method (CXK)  
% - Sufficiency of counterfactual to moments via delta method (CX1)
% - VCov of counterfactual via delta method (CXC)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [CfacLambda, CfacLambdaTilde, CfacDelta, CfacVcov] = ...
get_counterfactual_sensitivity(Lambda, cfac_jacobian, param_vcov, moment_vcov)

    CfacLambda = cfac_jacobian * Lambda;

    if nargin == 4
        CfacVcov = cfac_jacobian * param_vcov * cfac_jacobian';
        se_cfac = sqrt(diag(CfacVcov));
        se_mom = sqrt(diag(moment_vcov));
        CfacLambdaTilde = get_standardized_sensitivity(CfacLambda, se_cfac, se_mom);
        CfacDelta = get_sufficiency(CfacLambda, se_cfac, moment_vcov);
    else
        nargoutchk(0, 1); 
    end
end
