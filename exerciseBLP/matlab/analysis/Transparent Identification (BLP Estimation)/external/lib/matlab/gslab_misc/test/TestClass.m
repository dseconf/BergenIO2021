classdef TestClass

properties (Constant)
    property1 = 1;
end

properties (Dependent)
    property2;
end

properties
    property3 = 1;
end

properties (Transient)
    property4 = 1;
end

properties (Hidden)
    property5 = 1;
end

methods

    function obj = TestClass(varargin)
        if nargin> 0 && strcmp(class(varargin{1}), 'TestClass')
           obj = copyproperties(obj, varargin{1});
        end
    end

    function property2 = get.property2(obj)
        property2 = obj.property3*2;
    end
    
end

end
