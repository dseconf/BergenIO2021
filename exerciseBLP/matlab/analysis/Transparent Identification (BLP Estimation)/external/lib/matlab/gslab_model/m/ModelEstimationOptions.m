classdef (Abstract) ModelEstimationOptions
%
% ModelEstimationOptions defines options for the Estimate() method of
% Model.
%

properties
    quiet                   = 0           % Do not play output following estimation
    startparam              = []          % Starting paramter vector. If not specified, Estimate() uses default_startparam property of Model.
    ktr                     = []          % A valid Matlab options structure produced by optimset(). These options are handed directly to Knitro solver.
    ktrtxt                  = []          % Name of file defining additional options to be passed directly to Knitro. See knitroOptions in  'help ktrlink'.
    hesstol                 = 10^-4       % Numerical step for computing the Hessian.
end

methods
    function obj = ModelEstimationOptions(varargin)
        if nargin > 0
            obj.ktr = optimset('Display', 'iter');
            obj = obj.AssignOptions(varargin{:});
        end
    end   
end

methods (Hidden, Access = protected)
    function obj = AssignOptions(obj, varargin)
        option_struct = parse_option_list(varargin{:});
        for field = fieldnames(option_struct)'
            obj.(field{:}) = option_struct.(field{:});
        end
    end
end

end
