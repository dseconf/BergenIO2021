classdef BlpModel < MdeModel
%
% BlpModel is the MdeModel subclass for BLP models.
%

properties
    demand_varlist = {'const', 'hpwt', 'air', 'mpd', 'space'};
    supply_varlist = {'const', 'loghpwt', 'air', 'logmpg', 'logspace', 'trend'};
    demand_iv_varlist;     % Cell array of names of demand side instrumental variables
    supply_iv_varlist;     % Cell array of names of supply side instrumental variables
    demand_iv_varnames;    % Cell array of more descriptive demand side IV names
    supply_iv_varnames;    % Cell array of more descriptive supply side IV names
    iv_varnames;           % Cell array of more descriptive IV names
    demand_iv_indices;     % Vector of indices of iv_varnames that correspond to demand IVs
    supply_iv_indices;     % Vector of indices of iv_varnames that correspond to supply IVs
    delta_tol = 1e-14;     % Tolerance for delta in contraction mapping
    paramlist = {'alpha_price'};
    sigma_paramlist;       % Cell array of names of standard deviation parameters
    beta_paramlist;        % Cell array of names of mean parameters
    default_startparam;    % Default starting parameter value for estimate
    lhslist;               % Cell array of names of dependent (i.e., stochastic) variables
    rhslist;               % Cell array of names of independent (i.e., non-stochastic) variables
end

properties (Dependent)
    sigma_param_indices;      % Array of indices of standard deviation parameters
end

methods
    function obj = BlpModel(varargin)
        obj = obj@MdeModel(varargin{:});
        [obj.paramlist, obj.sigma_paramlist] = MdeModel.AddCoefficients(obj.paramlist, obj.demand_varlist, 0, 'sigma_', '');
        obj.beta_paramlist = [strcat('demand_', obj.demand_varlist), strcat('supply_', obj.supply_varlist)];
        obj.default_startparam = zeros(obj.nparam, 1);
        obj = obj.SetupInstruments({});
        assert(IsValidModel(obj));
    end
    
    function inds = get.sigma_param_indices(obj)
        inds = find(ismember(obj.paramlist, obj.sigma_paramlist));
    end
    
    [delta, mc, mu, market_share, indiv_market_share] = ComputeModelOutputs(obj, data, param);
    obj = LoadStartParam(obj, startparam_file);
    [market_share, indiv_market_share] = ComputeMarketShare(~, data, expdelta, expmu);
    mu = ComputeRandomUtility(obj, data, param);
    obj = SetupInstruments(obj, collinear_instruments, data, r2_tol, keep_means);
end

methods (Hidden, Access = protected)
    mc = ComputeMarginalCost(obj, data, param, delta, mu);
    [delta, niter] = DeltaContraction(obj, data, mu);
end

end