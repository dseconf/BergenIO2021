classdef MdeData < ModelData
%
% MdeData is the data class for MDE models.
%
methods
    function obj = MdeData(varargin)
        inputlist = ModelData.ParseInputList(varargin);
        obj.var = dataset(inputlist{:});
    end    
end

end