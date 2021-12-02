%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% LOGITINV: Inverse of the logit cumulative distribution function (cdf).
%           Type "help norminv" to view the help for the "normal distribution"
%               equivalent of this function.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = logitinv(p, shifter, scale)    
    if nargin==1
        shifter = 0;
        scale = 1;
    end
    x = shifter + scale * log(p ./ (1-p));
end