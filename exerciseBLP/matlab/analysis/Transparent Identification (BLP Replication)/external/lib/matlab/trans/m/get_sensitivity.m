%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET_SENSITIVITY.M
%
%   GET_SENSITIVITY(jacobian, weight) 
%   returns an a sensitivity matrix for any minimum distance estimator
%    as defined in Gentzkow and Shapiro (2013). 
%
%   If optional arguments se_param, se_mom are provided, the function 
%   additionally returns standardized sensitivity. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sensitivity, standardized_sensitivity] = get_sensitivity(jacobian, weight, se_param, se_mom)
    assert(det(jacobian' * jacobian) ~= 0); 
    sensitivity = - (jacobian' * weight * jacobian)^(-1) * (jacobian' * weight);
    
    if nargin == 4
        standardized_sensitivity = get_standardized_sensitivity(sensitivity, se_param, se_mom);
    else
        nargoutchk(0, 1); 
    end
end