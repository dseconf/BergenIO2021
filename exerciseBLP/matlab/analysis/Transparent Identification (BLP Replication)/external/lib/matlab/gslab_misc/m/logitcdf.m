%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% LOGITCDF: Logit cumulative distribution function (cdf).
%           Type "help normcdf" to view the help for the "normal distribution"
%               equivalent of this function.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = logitcdf(x, mean, disp)
    s = 1 ./ (1 + exp( -(x - mean) ./ disp ));
end