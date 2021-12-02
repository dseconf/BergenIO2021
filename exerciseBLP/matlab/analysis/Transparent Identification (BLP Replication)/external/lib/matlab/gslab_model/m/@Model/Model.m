classdef (Abstract) Model
%
% Model: Abstract class that provides a template for models
%
% To implement a model, the user defines a subclass of the abstract class Model. A valid 
% implementation must (i) specifiy the abstract properties which define the model's elements;
% (ii) implement the following method(s):
%
% bool = IsValidModel(obj)
%     Takes as a Model object, and returns a bool to indicate whether it is a valid instantiation.
% 
%     INPUTS
%       - obj: a Model object
% 
%     OUTPUTS
%       - bool: a boolean value indicating whether the Model object is valid
%

properties (Abstract)
    paramlist;              % Cell array of parameter names; this defines the parameter vector
    default_startparam;     % Default starting parameter value for estimate
    lhslist;                % Cell array of names of dependent (i.e., stochastic) variables
    rhslist;                % Cell array of names of independent (i.e., non-stochastic) variables
end

properties (Dependent)
    nparam;                 % Number of parameters
    indices;                % Struct giving the index of each parameter
end

methods (Abstract, Hidden, Access = protected)
    bool = IsValidModel(obj)
end

methods
    function n = get.nparam(obj)
        n = length(obj.paramlist);
    end

    function ind = get.indices(obj)
        ind = cell2struct(num2cell(1:obj.nparam)', obj.paramlist);
    end

end

methods (Hidden, Access = protected)
    function obj = AssignOptions(obj, varargin)
        option_struct = parse_option_list(varargin{:});
        for field = fieldnames(option_struct)'
            obj.(field{:}) = option_struct.(field{:});
        end
    end

    xbeta = XBeta(obj, varlist, data, param, include_constant, prefix, datavar_suffix, constname)
    bool = IsValidParameterVector(obj, param)
end

methods (Hidden, Static, Access = protected)
    [newlist indices] = AddCoefficients(paramlist, varlist, include_constant, prefix, suffix)
end

end

