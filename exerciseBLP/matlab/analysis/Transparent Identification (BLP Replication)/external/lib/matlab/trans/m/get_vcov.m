%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET_VCOV.M
%
%   GET_VCOV( jacobian, vcov_mom, weight ) 
%   returns variance-covariance matrix for model parameters
%   (see Greene (2012) Thm 13.1)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ vcov_param ] = get_vcov( jacobian, vcov_mom, weight )
    outer = (jacobian'*weight*jacobian)^(-1);
    inner = (jacobian'*weight*vcov_mom*weight*jacobian);
    
    vcov_param = outer*inner*outer;
end