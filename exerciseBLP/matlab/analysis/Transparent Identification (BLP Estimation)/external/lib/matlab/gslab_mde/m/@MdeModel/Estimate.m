function est = Estimate(obj, data, wmatrix, estopts)
% Estimates an MdeModel with weight matrix.
%
% INPUTS
%   - data: An MdeData object.
%   - wmatrix: An postive non-definite matrix.
%   - estopts: An MdeEstimationOptions object
%
% OUTPUTS
%   - est: An MdeEstimationOutput object.
%

    if nargin == 2
        estopts = MdeEstimationOptions();
    end

    if estopts.quiet == 1
        estopts.ktr = optimset(estopts.ktr, 'Display', 'off');
    end
    
    estopts.startparam = set_startparam(obj, estopts);
    
    % Main call to Knitro solver
    [slvr.paramhat, slvr.fval, slvr.exitflag, slvr.output, slvr.lambda] = ...
        ktrlink(@(param)wtd_dist(obj, param, data, wmatrix), estopts.startparam, ...
        [], [], [], [], ...
        [], [], [], estopts.ktr); 
    
    slvr.gjacobian = compute_jacobian(obj, slvr.paramhat, data, estopts);
    slvr.Omega = compute_omega(obj, slvr.paramhat, data);  
    slvr.wmatrix = wmatrix;
    
    est = MdeEstimationOutput(slvr, estopts, obj, data);
end

function startparam = set_startparam(obj, estopts)
    if isempty(estopts.startparam)
        startparam = obj.default_startparam;
    else
        startparam = estopts.startparam;
    end
    assert( obj.IsValidParameterVector(startparam) );
end

function q = wtd_dist(obj, param, data, wmatrix)
    g = ComputeDistanceVector(obj, param, data);
    q = g' * wmatrix * g; 
end

function omega = compute_omega(obj, param, data)
% Computes sample covariance matrix of g at param
    nobs = data.nobs;
    dist = length(ComputeDistanceVector(obj, param, data));
    g = zeros(nobs, dist);
    for i = 1:nobs
        data_i = data.Select(i, :);
        g(i,:) = ComputeDistanceVector(obj, param, data_i);
    end
    gg = g - ones(nobs, 1) * mean(g);
    omega = (1 / nobs) * (gg') * gg;
end

function [jacobian] = compute_jacobian(obj, paramhat, data, estopts)  
    jacobian = NumJacob(@(param)ComputeDistanceVector(obj, param, data), paramhat, estopts.hesstol);    
end
