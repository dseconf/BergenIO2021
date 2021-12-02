classdef ExampleData < ModelData

methods
    function obj = ExampleData(varargin)
        inputlist = ModelData.ParseInputList(varargin);
        obj.var = dataset(inputlist{:});
    end    
end

end