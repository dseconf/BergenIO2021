classdef LinearGMMModel < MdeModel
%
% LinearGMMModel implements MdeModel class for the Linear GMM Model.
%
properties
    paramlist = {};
    default_startparam = [];
    lhslist = '';
    rhslist = {};
    instrlist = {};
    include_constant = true;        % Estimate model with constant term
end

methods
    function obj = LinearGMMModel(lhs, rhs, instr, varargin)
        obj = obj@MdeModel(varargin{:});
        obj.lhslist = lhs;
        obj.rhslist = rhs;
        obj.paramlist = MdeModel.AddCoefficients(obj.paramlist, rhs, obj.include_constant);
        obj.default_startparam = zeros(obj.nparam, 1);
        if nargin > 2
            assert(length(instr) >= length(rhs));
            obj.instrlist = instr; 
        else
            obj.instrlist = rhs;
        end
        assert( IsValidModel(obj) ); 
    end
    
    function g = ComputeDistanceVector(obj, param, data) 
        y = data.GetArray(obj.lhslist);
        xb = obj.XBeta(obj.rhslist, data, param, obj.include_constant);
        z = data.GetArray(obj.instrlist);
        if obj.include_constant
            z = [z ones(data.nobs,1)];
        end
        g = (1/data.nobs) * (z)' * (y - xb);
    end
end

end

