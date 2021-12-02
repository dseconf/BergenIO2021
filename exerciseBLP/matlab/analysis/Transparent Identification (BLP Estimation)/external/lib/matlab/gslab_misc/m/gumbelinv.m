function x = gumbelinv(p,shifter,scale)
%
% GUMBELINV: Inverse of the Gumbel (Type-I extrme value) cumulative distribution 
%           function (cdf). Type "help norminv" to view the help for the 
%           "normal distribution" equivalent of this function.
%

    if nargin==1
        shifter = 0;
        scale = 1;
    end

    x = shifter - scale * log( -log(p) );
end