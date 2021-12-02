%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET_SAMPLE_SENSITIVITY.M
%
%   GET_SAMPLE_SENSITIVITY(jacobian, ahat, weight) 
%   returns a sample sensitivity matrix for any minimum distance estimator. 
%
%   If optional arguments se_param, se_mom are provided, the function 
%   additionally returns standardized sensitivity. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sample_sensitivity, standardized_sample_sensitivity] = get_sample_sensitivity(jacobian, ahat, weight, se_param, se_mom)
    assert(det(jacobian' * weight * jacobian + ahat) ~= 0); 

    sample_sensitivity = - (jacobian' * weight * jacobian + ahat)^(-1) * (jacobian' * weight);
    
    if nargin == 5
        standardized_sample_sensitivity = get_standardized_sensitivity(sample_sensitivity, se_param, se_mom);
    else
        nargoutchk(0, 1); 
    end
end