classdef ExampleEstimationOutput < ModelEstimationOutput

properties (Dependent)
    vcov        % Variance-covariance matrix of parameters
end

methods
    function obj = ExampleEstimationOutput(slvr, estopts, model, data)
        obj = obj@ModelEstimationOutput(slvr, estopts, model, data);
    end
    
    function vcov = get.vcov(obj)
        % always returns the identity matrix
        vcov = eye(obj.model.nparam);
    end
end

end