classdef BlpEstimationOutput < MdeEstimationOutput
%
% BlpEstimationOutput holds estimates of the BLP model and computes post-estimation objects.
%

properties
    beta;                   % Vector of mean parameters
    unobs;                  % Array of unobservables
    unobs_income;           % Vector of unobservables for income
    unobs_weight;           % Vector of weights for unobservables
    g;                      % Vector of distances
    g_model;                % Vector of sum of distances for each model
    
    firststage_param;       % Vector of estimated parameters
    firststage_fval;        % Likelihood value at estimated parameters
    firststage_exitflag;    % Knitro exitflag (see 'help ktrlink')
    firststage_output;      % Knitro output with info on optimization (see 'help ktrlink')
    firststage_lambda;      % Lagrange multipliers at estimated parameters (see 'help ktrlink')
    
    importance_sample;      % Switch for importance sampling
    nmodels;                % Number of car models in data
    log_income_mean;        % Vector of means for log income
    log_income_sd;          % Scalar of standard deviation for log income
end

methods
    function obj = BlpEstimationOutput(slvr_firststage, slvr_final, estopts, model, data)
        obj = obj@MdeEstimationOutput(slvr_final, estopts, model, data);
        
        obj.firststage_param = slvr_firststage.paramhat;
        obj.firststage_fval = slvr_firststage.fval;
        obj.firststage_exitflag = slvr_firststage.exitflag;
        obj.firststage_output = slvr_firststage.output;
        obj.firststage_lambda = slvr_firststage.lambda;
        
        obj.beta = slvr_final.betahat;
        obj.g = slvr_final.g;
        obj.g_model = slvr_final.g_model;
        obj.gjacobian = slvr_final.gjacobian;
        obj.wmatrix = slvr_final.wmatrix;
        obj.Omega = slvr_final.Omega;
        
        obj.nobs = data.nobs;
        obj.nmodels = data.nmodels;
        obj.unobs = data.unobs;
        obj.unobs_income = data.unobs_income;
        obj.unobs_weight = data.unobs_weight;
        
        obj.log_income_mean = data.const.log_income_mean;
        obj.log_income_sd = data.const.log_income_sd;
        
        obj.importance_sample = ~all(obj.unobs_weight == 1);
    end
    
    attribute_elasticity = ComputeAttributeElasticity(obj, data, varname, param, beta)
    price_elasticity = ComputePriceElasticity(obj, data, param)
    Play(obj, model);
end

end