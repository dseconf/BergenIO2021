classdef MdeEstimationOptions < ModelEstimationOptions
%
% MdeEstimationOptions defines options for the Estimate() method of
% MdeModel.
%

methods
    function obj = MdeEstimationOptions(varargin)
        if nargin > 0
            obj.ktr = optimset('Display', 'iter');
            obj = obj.AssignOptions(varargin{:});
        end
    end   
end

end