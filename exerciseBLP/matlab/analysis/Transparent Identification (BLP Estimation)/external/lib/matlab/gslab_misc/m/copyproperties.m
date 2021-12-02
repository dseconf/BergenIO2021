function obj = copyproperties(obj, model, varargin)
%
% Copy the properties of object model to object obj
% 
% INPUTS
%
%    - obj: Target object.  Properties of 'model' are copied to this
%    object. 'obj' should be an instance of the same class as 'model', 
%    or of a subclass of that class.
%
%    - model: Object with properties to be copied.
%
%    - varargin: List of properties of 'model' to be excluded from the copy.
%
% OUTPUTS
%
%    - obj: Input object 'obj', with properties reassigned to those of 'model'.
%

properties = fieldnames(model);
meta = metaclass(model);

if nargin > 2
    for i = 1:(nargin - 2)
        model.(varargin{i}) = obj.(varargin{i});
    end
end

for i = 1:numel(properties)
    if meta.PropertyList(i,1).Constant == 0 && meta.PropertyList(i,1).Dependent == 0;
        obj.(properties{i}) = model.(properties{i});
    end
end

end
