classdef ExampleModel < Model

properties
    paramlist = {};
    default_startparam = [];
    lhslist = '';
    rhslist = {};
    include_constant = 1; 
end

methods
    function obj = ExampleModel(lhs, rhs, varargin)
        obj = obj@Model(varargin{:});
        obj.lhslist = lhs;
        obj.rhslist = rhs;
        obj.paramlist = Model.AddCoefficients(obj.paramlist, rhs, obj.include_constant);
        obj.default_startparam = zeros(obj.nparam, 1);
        assert( IsValidModel(obj) );
    end
    
    function est = Estimate(obj, data, estopts)
        % Estimate minimizes objective function of param'*param
        [slvr.paramhat, slvr.fval, slvr.exitflag, slvr.output, slvr.lambda] = ...
            ktrlink(@(param)param'*param, estopts.startparam, ...
                    [], [], [], [], [], [], [], estopts.ktr);
        est = ExampleEstimationOutput(slvr, estopts, obj, data);
    end
end 

methods (Hidden, Access = protected)
    function bool = IsValidModel(obj)
        bool = true;
        % all lists are cell arrays of strings that are either empty or row arrays
        for listname = {'paramlist'}
            list = obj.(listname{:});
            bool = bool && iscellstr(list) && (isempty(list) || size(list,1)==1);
        end
    end
end

end
