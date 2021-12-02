function est = Estimate(obj, data, wmatrix, estopts)
%
% Estimates a BlpModel with weight matrix.
%
%
% INPUTS
%   - data:    BlpData object
%   - wmatrix: Positive non-definite matrix
%   - estopts: BlpEstimationOptions object
%
% OUTPUTS
%   - est: BlpEstimationOutput object
%

    if nargin == 2
        estopts = BlpEstimationOptions();
    end

    if estopts.quiet == 1
        estopts.ktr = optimset(estopts.ktr, 'Display', 'off');
    end
    
    estopts.startparam = set_startparam(obj, estopts);
    
    demand_iv_var = data.GetArray(obj.demand_iv_varlist);
    supply_iv_var = data.GetArray(obj.supply_iv_varlist);
    z = blkdiag(demand_iv_var, supply_iv_var);
    
    % Computes moments at parameter guess to obtain optimal weight matrix
    proj_z = z*wmatrix*z';    % Pre-computes projection matrix to save time
    [~, g_model] = obj.ComputeDistanceVector(data, estopts.startparam, proj_z);
    wmatrix = inv(cov(g_model));
    proj_z = z*wmatrix*z';
    
    % First stage GMM call to Knitro solver
    [slvr.paramhat, slvr.fval, slvr.exitflag, slvr.output, slvr.lambda] = ...
        ktrlink(@(param)wtd_dist(obj, param, data, wmatrix, proj_z), estopts.startparam, ...
        [], [], [], [], ...
        estopts.lower_bound, estopts.upper_bound, [], estopts.ktr);
    slvr_firststage = slvr;
    
    % Updates weight matrix using new parameter estimates
    [~, g_model] = obj.ComputeDistanceVector(data, slvr_firststage.paramhat, proj_z);
    wmatrix = inv(cov(g_model));
    proj_z = z*wmatrix*z';
    
    estopts.startparam = slvr_firststage.paramhat;
    
    % Second stage GMM call to Knitro solver
    [slvr.paramhat, slvr.fval, slvr.exitflag, slvr.output, slvr.lambda] = ...
        ktrlink(@(param)wtd_dist(obj, param, data, wmatrix, proj_z), estopts.startparam, ...
        [], [], [], [], ...
        estopts.lower_bound, estopts.upper_bound, [], estopts.ktr);
    slvr_final = slvr;
    
    [slvr_final.g, slvr_final.g_model, ~, slvr_final.betahat] = obj.ComputeDistanceVector(data, slvr_final.paramhat, proj_z);
    slvr_final.gjacobian = ...
        compute_jacobian(obj, data, slvr_final.paramhat, slvr_final.betahat, proj_z, estopts);
    slvr_final.Omega = compute_omega(obj, data, slvr_final.paramhat, proj_z);
    slvr_final.wmatrix = wmatrix;
    
    est = BlpEstimationOutput(slvr_firststage, slvr_final, estopts, obj, data);
end

function startparam = set_startparam(obj, estopts)
    if isempty(estopts.startparam)
        startparam = obj.default_startparam;
    else
        startparam = estopts.startparam;
    end
    assert( obj.IsValidParameterVector(startparam) );
end

function q = wtd_dist(obj, param, data, wmatrix, proj_z)
    g = obj.ComputeDistanceVector(data, param, proj_z);
    q = g' * wmatrix * g; 
end

% Computes sample covariance matrix of g at param
function omega = compute_omega(obj, data, param, proj_z)    
    [~, g_model] = obj.ComputeDistanceVector(data, param, proj_z);
    omega = cov(g_model);
end

function jacobian = compute_jacobian(obj, data, paramhat, betahat, proj_z, estopts)
    jacobian_param = NumJacob(@(param)obj.ComputeDistanceVector(data, param, proj_z, betahat), paramhat, estopts.hesstol);
    jacobian_beta = NumJacob(@(beta)obj.ComputeDistanceVector(data, paramhat, proj_z, beta), betahat, estopts.hesstol);
    jacobian = [jacobian_param, jacobian_beta];
end
