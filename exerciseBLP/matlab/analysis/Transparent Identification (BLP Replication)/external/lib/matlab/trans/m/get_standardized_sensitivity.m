%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET_STANDARDIZED_SENSITIVITY.M
%
%   get_standardized_sensitivity(sensitivity, se_param, se_mom) 
%   returns an a standardized sensitivity matrix given a sensitivity matrix
%   and appropriate standard errors. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function standardized_sensitivity = get_standardized_sensitivity(sensitivity, se_param, se_mom)
    scaled_by = repmat(se_mom, 1, length(se_param))' ./ repmat(se_param, 1, length(se_mom)); 
    standardized_sensitivity = sensitivity .* scaled_by; 
end