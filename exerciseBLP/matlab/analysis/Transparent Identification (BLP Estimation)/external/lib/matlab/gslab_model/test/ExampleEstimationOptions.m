classdef ExampleEstimationOptions < ModelEstimationOptions

methods
    function obj = ExampleEstimationOptions(varargin)
        if nargin > 0
            obj.ktr = optimset('Display', 'iter');
            obj = obj.AssignOptions(varargin{:});
        end
    end   
end

end