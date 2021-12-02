classdef BlpData < ModelData
%
% BlpData is the ModelData subclass for BLP models.
%

properties
    % Struct to hold variable names as they correspond to dataset variables
    varlist = ...
        struct('unobs_vars', {{'const', 'hpwt', 'air', 'mpd', 'space'}}, ...
               'demand_iv_basis', {{'const', 'hpwt', 'air', 'mpd', 'space'}}, ...
               'supply_iv_basis', {{'const', 'loghpwt', 'air', 'logmpg', 'logspace', 'trend'}}, ...
               'market', {{'year'}}, ...
               'firm', {{'firm_id'}}, ...
               'model', {{'model_id'}}, ...
               'observed_share', {{'share'}}, ...
               'logit_depvar', {{'logit_depvar'}}, ...
               'price', {{'price'}});
    unobs = [];               % Array of unobservables
    unobs_income = [];        % Vector of unobservables for income
    unobs_weight = [];        % Vector of weights for unobservables
    unobs_year = [];          % Vector of years for unobservables
    income = [];              % Array of random income
end

properties (Dependent)
    market_levels;            % Unique levels of markets
    model_levels;             % Unique levels of models
    nmarkets;                 % Number of markets
    nmodels;                  % Number of models
    nunobs;                   % Number of individuals
    nvars_unobs;              % Number of demand-side product attributes
end

methods
    function obj = BlpData(data_file, income_means_file, income_sd_file, unobs_file)
        % Create new BlpData object
        obj.var = dataset('File', data_file, 'Delimiter', ',');
        obj.var = obj.RemoveNaN();
        if ~ismember('firm_id', obj.varnames)
            obj.varlist.firm = {'firmid'};
        end
        
        % Create derived variables
        obj.var = obj.AddDerivedVariables();
        [obj.var, obj.varlist.demand_firm_sum] = ...
            obj.GenInstruments([obj.varlist.market, obj.varlist.firm], ...
                               obj.varlist.demand_iv_basis, ...
                               'demand_firm', ...
                               {obj.varlist.demand_iv_basis});
        [obj.var, obj.varlist.demand_rival_sum] = ...
            obj.GenInstruments(obj.varlist.market, ...
                               obj.varlist.demand_iv_basis, ...
                               'demand_rival', ...
                               {obj.varlist.demand_iv_basis, obj.varlist.demand_firm_sum});
        [obj.var, obj.varlist.supply_firm_sum] = ...
            obj.GenInstruments([obj.varlist.market, obj.varlist.firm], ...
                               obj.varlist.supply_iv_basis, ...
                               'supply_firm', ...
                               {obj.varlist.supply_iv_basis});
        [obj.var, obj.varlist.supply_rival_sum] = ...
            obj.GenInstruments(obj.varlist.market, ...
                               obj.varlist.supply_iv_basis, ...
                               'supply_rival', ...
                               {obj.varlist.supply_iv_basis, obj.varlist.supply_firm_sum});
        
        obj = obj.AddIncomeParams(income_means_file, income_sd_file);
        if nargin < 4
            obj = obj.DrawUnobservables(200);    % Defaults number of unobservables to 200
        else
            obj = obj.LoadUnobservablesFromFile(unobs_file);
        end
    end
    
    function n = get.nmarkets(obj)
        n = length(obj.market_levels);
    end
    
    function n = get.nmodels(obj)
        n = length(unique(obj.GetArray(obj.varlist.model)));
    end
    
    function levels = get.market_levels(obj)
        levels = unique(obj.GetArray(obj.varlist.market));
    end
    
    function levels = get.model_levels(obj)
        levels = unique(obj.GetArray(obj.varlist.model));
    end
    
    function n = get.nunobs(obj)
        assert(~isempty(obj.unobs));
        n = size(obj.unobs, 1);
    end
    
    function n = get.nvars_unobs(obj)
        n = length(obj.varlist.unobs_vars);
    end
    
    function obj = Select(obj, varargin)
        obj.var = obj.var(varargin{:});
        obj.income = obj.income(varargin{1}, :);
        if ~isempty(obj.groupvar)
            obj.groupvar = obj.groupvar(varargin{1});
        end
    end
    
    function obj = SelectUnobs(obj, keep, weight)
        obj.unobs = obj.unobs(keep, :);
        obj.unobs_income = obj.unobs_income(keep);
        obj.unobs_year = obj.unobs_year(keep);
        obj.income = obj.income(:, keep);
        obj.unobs_weight = weight;
        assert(length(obj.unobs_weight) == size(obj.unobs, 1));
    end
    
    obj = AddIncomeParams(obj, means_file, sd_file);
    obj = DrawUnobservables(obj, nunobs);
    [var, iv_varnames] = GenInstruments(obj, group_key, x_var, gen_prefix, exclude_varlist);
    obj = LoadUnobservablesFromEstimate(obj, est);
    obj = LoadUnobservablesFromFile(obj, filename);
    data_cell = SplitDataByMarket(obj)
    bootsample_cell = DrawBootstrapSamples(obj, numbootstrap, unobs_per_market); 
end

methods (Static)
    [data_out, r2] = RemoveCollinearity(~, data_in, r2_tol);
    
    function var = CreateDemeanedVariables(var, varlist)
        for varname = varlist
            demeaned_varname = strcat('demeaned_', varname{:});
            var.(demeaned_varname) = var.(varname{:}) - mean(var.(varname{:}), 1);
        end
    end
end

methods (Hidden, Access = protected)
    function var = RemoveNaN(obj)
        for varname = obj.varnames
            vararray = obj.var.(varname{:});
            if ~iscell(vararray) && all(isnan(vararray))
                obj = obj.RemoveData(varname{:});
            end
        end
        var = obj.var;
    end
    
    function income = ComputeIncome(obj)
        income = exp(repmat(obj.var.log_income_mean, 1, obj.nunobs) + ...
            obj.const.log_income_sd * repmat(obj.unobs_income', obj.nobs, 1));
    end
    
    function var = AddDerivedVariables(obj)
        var = obj.var;
        var.model_id_str = var.model_id;
        var.model_id = grp2idx(var.model_id);
        var.loghpwt = log(var.hpwt);
        var.logmpg = log(var.mpg);
        var.logspace = log(var.space);
        
        var = BlpData.CreateDemeanedVariables(var, obj.varlist.demand_iv_basis);
        var = BlpData.CreateDemeanedVariables(var, obj.varlist.supply_iv_basis);
    end
end

end