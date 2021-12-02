classdef (Abstract) MdeModel < Model
%
% MdeModel: Abstract class that provides a template for user-defined minimum distance models
%
% To implement a model, the user defines a subclass of the abstract class MdeModel. A valid 
% implementation must (i) specifiy the abstract properties which define the model's elements;
% (ii) implement the following method:
%
% g = ComputeDistanceVector(obj, param, data)
%     Takes as input a parameter vector and data, 
%     including values for all unobservables, and returns a g vector as defined in 
%      Newey and McFadden 1994. 
% 
%     INPUTS
%       - param: Vector of parameters at which to compute distances.
%       - data: A MdeData() object.
% 
%     OUTPUTS
%       - g: A real vector of distances.
%

methods (Abstract)
    g = ComputeDistanceVector(obj, param, data)
end

methods
    function obj = MdeModel(varargin)
        if nargin > 0 && ~(nargin == 1 && IsValidModel(varargin{1}))
            obj = obj.AssignOptions(varargin{:});
        end
        assert( IsValidModel(obj) );
    end
    
    est = Estimate(obj, data, wmatrix, estopts)
end 

methods (Hidden, Access = protected)
    bool = IsValidModel(obj)
end

end
