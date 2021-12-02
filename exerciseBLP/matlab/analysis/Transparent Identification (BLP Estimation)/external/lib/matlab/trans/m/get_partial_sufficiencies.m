%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GET_PARTIAL_SUFFICIENCIES
% 
% Takes as input:
% - Parameter list (PX1)
% - Moment list (MX1)
% - Key moments for parameters (as cell array of space-delimited lists or cell
%       array of cell arrays) (PX1)
% - Sensitivity matrix lambda (PXM)
% - SEs of parameters (PX1)
% - VCov of moments (MXM)
%
% Returns as output: 
% - Sufficiency of the key moments of each parameter (PX1)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ps = get_partial_sufficiencies(paramlist, momlist, key_mom, Lambda, param_se, moment_vcov)
    ps = zeros(length(paramlist), 1);
    for i = 1 : length(paramlist)
        if ischar(key_mom{i})
            key_mom_param = regexp(key_mom{i}, ' ', 'split');
        else
            key_mom_param = key_mom{i};
        end
        moment_indices = arrayfun( @(x)(find(strcmp(x, momlist),1,'first')), key_mom_param );
        ps_param = get_sufficiency(Lambda, param_se, moment_vcov, moment_indices');
        ps(i) = ps_param(i);
    end
end