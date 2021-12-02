function obj = SetupInstruments(obj, collinear_instruments, data, r2_tol, keep_means)
%
% Sets up instruments by removing collinear instruments and adjusting names.
%
% 
% INPUTS
%     - collinear_instruments: Cell array of list of instruments to remove.
%     - data (optional):       BlpData object, for automatic collinearity removal of instruments.
%     - r2_tol (optional):     Scalar tolerance for automatic collinearity removal of instruments.
%     - keep_means (optional): Do not demean instruments.
%

obj.demand_iv_varlist = [obj.demand_varlist, strcat('demand_firm_', obj.demand_varlist), ...
    strcat('demand_rival_', obj.demand_varlist)];
obj.supply_iv_varlist = [obj.supply_varlist, strcat('supply_firm_', obj.supply_varlist), ...
    strcat('supply_rival_', obj.supply_varlist), 'mpd'];

obj.demand_iv_varlist = setdiff(obj.demand_iv_varlist, collinear_instruments, 'stable');
obj.supply_iv_varlist = setdiff(obj.supply_iv_varlist, collinear_instruments, 'stable');

% Remove instruments due to collinearity based on tolerance for R^2 from
% regression of kept instruments on each instrument
if nargin >= 3
    assert(nargin >= 4);
    demand_iv_var = data.GetArray(obj.demand_iv_varlist);
    [~, r2] = BlpData.RemoveCollinearity(demand_iv_var, r2_tol);
    obj.demand_iv_varlist = obj.demand_iv_varlist(r2 <= r2_tol);
    
    supply_iv_var = data.GetArray(obj.supply_iv_varlist);
    [~, r2] = BlpData.RemoveCollinearity(supply_iv_var, r2_tol);
    obj.supply_iv_varlist = obj.supply_iv_varlist(r2 <= r2_tol);
end

% More informative IV names for output
obj.demand_iv_varnames = strcat('demand_', obj.demand_iv_varlist);
obj.demand_iv_varnames = strrep(obj.demand_iv_varnames, 'demand_demand_', 'demand_');
obj.supply_iv_varnames = strcat('supply_', obj.supply_iv_varlist);
obj.supply_iv_varnames = strrep(obj.supply_iv_varnames, 'supply_supply_', 'supply_');
obj.iv_varnames = [obj.demand_iv_varnames, obj.supply_iv_varnames];

obj.demand_iv_indices = find(ismember(obj.iv_varnames, obj.demand_iv_varnames));
obj.supply_iv_indices = find(ismember(obj.iv_varnames, obj.supply_iv_varnames));

if nargin < 5 || keep_means == false
    obj.demand_iv_varlist = generate_demeaned_varlist(obj.demand_iv_varlist);
    obj.supply_iv_varlist = generate_demeaned_varlist(obj.supply_iv_varlist);
end
end

function demeaned_varlist = generate_demeaned_varlist(varlist)
    demeaned_varlist = strcat('demeaned_', varlist);
    demeaned_varlist = strrep(demeaned_varlist, 'demeaned_const', 'const');
end