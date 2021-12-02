classdef MdeEstimationOutput < ModelEstimationOutput
%
% MdeEstimationOutput holds estimates of the MDE model.
%

properties
    wmatrix;     % Weight matrix
    Omega;       % Vcov computed from data
    gjacobian;   % Jacobian of distance vector eval at paramhat
end

properties (Dependent)
    vcov        % Variance-covariance matrix of parameters
end

methods
    function obj = MdeEstimationOutput(slvr, estopts, model, data)
        obj = obj@ModelEstimationOutput(slvr, estopts, model, data);
        obj.gjacobian = slvr.gjacobian;
        obj.wmatrix = slvr.wmatrix;
        obj.Omega = slvr.Omega;
        obj.nobs = data.nobs;
    end
    
    function vcov = get.vcov(obj)
        vcov = obj.ComputeVCov(obj.gjacobian, obj.wmatrix, obj.Omega, obj.nobs);
    end
end

methods (Static, Access = private)
    vcov = ComputeVCov(gjacobian, wmatrix, Omega, nobs);
end    

end