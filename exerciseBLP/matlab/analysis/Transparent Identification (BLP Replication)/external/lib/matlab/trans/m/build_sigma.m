%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% BUILD_SIGMA
% 
% Takes as input:
% - Sensitivity matrix lambda (PXM)
% - VCov of parameters (PXP)
% - VCov of moments (MXM)
%
% Returns as output: 
% - Full variance-covariance matrix (P+M X P+M) for moments and parameters 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Sigma, Sigma_tt, Sigma_tg, Sigma_gg] = build_sigma(Lambda, param_vcov, moment_vcov)
    Sigma_tt = param_vcov;
    Sigma_tg = Lambda * moment_vcov;
    Sigma_gg = moment_vcov;
    Sigma = [Sigma_tt Sigma_tg; Sigma_tg' Sigma_gg];
end