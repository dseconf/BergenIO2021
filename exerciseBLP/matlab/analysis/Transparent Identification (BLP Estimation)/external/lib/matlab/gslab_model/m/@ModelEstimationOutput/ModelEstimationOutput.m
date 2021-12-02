classdef (Abstract) ModelEstimationOutput
%
% ModelEstimationOutput 
%
% To implement a model, the user defines a subclass of the abstract class ModelEstimationOutput. A valid 
% implementation must (i) specifiy the abstract properties which define the model's elements;
% (ii) implement the following get method(s) for the dependent abstract properties:
%
% get.vcov(obj)
%     Takes as a Model object, and returns a variance-covariance matrix for estimated parameters.
% 
%     INPUTS
%       - obj: a Model object.
% 
%     OUTPUTS
%       - bool: a variance-covariance matrix for estimated parameters.

properties
    param;       % Vector of estimated parameters
    fval;        % Likelihood value at estimated parameters
    exitflag;    % Knitro exitflag (see 'help ktrlink')
    output;      % Knitro output with info on optimization (see 'help ktrlink')
    lambda;      % Lagrange multipliers at estimated parameters (see 'help ktrlink')
    estopts;     % Estimation options
    model;       % Model object that was estimated
    nobs;        % Number of observations in the data used for estimation
end

properties (Abstract, Dependent)
    vcov;        % Variance-covariance matrix of parameters
end

properties (Dependent)
    se;          % Standard errors of parameters
end

methods
    function obj = ModelEstimationOutput(slvr, estopts, model, data)
        obj.param = slvr.paramhat;
        obj.fval = slvr.fval;
        obj.exitflag = slvr.exitflag;
        obj.output = slvr.output;
        obj.lambda = slvr.lambda;
        obj.estopts = estopts;
        obj.model = model;
        obj.nobs = data.nobs;
    end

    function se = get.se(obj)
        se = sqrt(diag(obj.vcov));
    end
end

end