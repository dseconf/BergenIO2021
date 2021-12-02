classdef ModelData
%
% ModelData is the data class for models.
%
% An ModelData object's data is stored in the var property, which is a Matlab dataset object.
% It can have an arbitrary number of data fields. Each data field 
% must be a numeric / cell / boolean array of dimension <=2.
%
% The property var contains a vector identifying groups in the panel. This vector must be sorted in
% ascending order with length equal to the row dimension of the var property.
%
% The constructor ModelData() accepts the same inputs as the constructor for the Matlab dataset class.
%
% Examples:
%    data = ModelData();
%    data = ModelData(x, y, z);
%    display(data.var.y);
%
%    mystruct.a = 1;
%    mystruct.b = 2;
%    data = ModelData(x, mystruct);
%    display(data.var.x);
%    display(data.var.a);
%

properties
    var = dataset()         % Dataset object to hold actual data variables
    const = struct()        % Struct to hold constants characterizing the dataset
    groupvar = []           % Variable identifying groups in panel
end

properties (SetAccess = protected)
    ngroups                 % Number of groups in panel
    group_size              % Vector of size ngroups x 1 giving number of observations in each group
    unique_group_sizes      % Unique group sizes that appear in the data
    nobs                    % Number of observations in the dataset
end

properties (Dependent)
    nvars           % Number of variables
    varnames        % List of names of variables in dataset
end

methods
    function obj = ModelData(varargin)
        % Create new ModelData object
        inputlist = ModelData.ParseInputList(varargin);
        obj.var = dataset(inputlist{:});
    end

    function n = get.nobs(obj)
        n = length(obj.var);
    end

    function n = get.nvars(obj)
        n = length(obj.var.Properties.VarNames);
    end

    function list = get.varnames(obj)
        list = sort(obj.var.Properties.VarNames);
    end

    function obj = set.var(obj, value)
        obj.var = value;
        obj.nobs = length(obj.var);
        obj.var.obsindex = (1:length(obj.var))';
    end

    function obj = set.groupvar(obj, value)
        obj.groupvar = value;
        obj.ngroups = length(unique(obj.groupvar));
        obj.group_size = sumwithin(ones(obj.nobs,1), obj.groupvar);
        obj.unique_group_sizes = unique(obj.group_size);
        obj.AssertValidGroupVar;
    end

    function bool = IsVariable(obj, varname)
        bool = any(ismember(obj.varnames, varname));
    end

    function obj = AddData(obj, varargin)
        inputlist = ModelData.ParseInputList(varargin, 1);
        newdata = dataset(inputlist{:});
        for name = newdata.Properties.VarNames
            obj.var.(name{:}) = newdata.(name{:});
        end
    end

    function obj = RemoveData(obj, varargin)
        inputlist = ModelData.ParseInputList(varargin, 1);
        for name = inputlist
            if any(strcmp(name{:},obj.varnames));
                obj.var.(name{:}) = [];
            end
        end
    end
    
    function obj = Select(obj, varargin)
        obj.var = obj.var(varargin{:});
        if ~isempty(obj.groupvar)
            obj.groupvar = obj.groupvar(varargin{1});
        end
    end

    function array = GetArray(obj, varlist)
        if nargin==1 || isempty(varlist)
            array = double(obj.var);
        else
            array = double(obj.var, varlist);
        end
    end
end

methods (Hidden, Access = protected)
    function AssertValidGroupVar(obj)
        if ~isempty(obj.groupvar)
            assert(all( obj.groupvar(2:end) - obj.groupvar(1:end-1) >= 0 ),...
                'Group variable not sorted');
            assert(isequal(length(obj.groupvar), obj.nobs),... 
                'Length of groupvar does not match data');
        end
    end
end

methods (Static, Hidden, Access = protected)
    function out = ParseInputList(list, offset)
    % This method replaces workspace variables appearing in the first part of the input list
    % with {var, 'name'} pairs. It also replaces struct inputs with {array, 'name1'} pairs
    % for each field.
        out = {};
        if nargin==1
            offset = 0;
        end
        for i = 1:length(list)
            if isnumeric(list{i}) || iscellstr(list{i})
                % Retrieve correct name of input variable from calling workspace
                inputname = evalin('caller', ['inputname (' num2str(offset+i) ')']);
                out = [out {{list{i}, inputname}}]; 
            elseif isstruct(list{i}) && ~isempty(fieldnames(list{i}))
                for name = fieldnames(list{i})'
                    out = [out {{list{i}.(name{:}) name{:}}}];
                end
            elseif ischar(list{i})
                out = [out list{i:end}];
                break;
            end
        end
    end
end

end