classdef BlpEstimationOptions < MdeEstimationOptions
%
% BlpEstimationOptions defines options for the Estimate() method of BlpModel.
%

properties
    lower_bound = []    % Lower bound for parameters
    upper_bound = []    % Upper bound for parameters
end

methods
    function obj = BlpEstimationOptions(varargin)
        if nargin > 0
            obj.ktr = optimset('Display', 'iter');
            obj = obj.AssignOptions(varargin{:});
        end
    end   
end

end