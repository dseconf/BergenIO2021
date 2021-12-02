classdef Blp1995ErroneousData < BlpData
%
% Blp1995ErroneousData is the BlpData subclass for data with error in
% instrument computation similar to those noted in BLP (1999) code.
% These instruments were used in BLP (1995).
%

methods
    function obj = Blp1995ErroneousData(varargin)
        obj = obj@BlpData(varargin{:});
        
        remove_vars = [obj.varlist.demand_firm_sum, obj.varlist.demand_rival_sum, ...
                       obj.varlist.supply_firm_sum, obj.varlist.supply_rival_sum];
        for var = remove_vars
            obj = obj.RemoveData(var{:});
        end
        
        [obj.var, obj.varlist.demand_firm_sum] = ...
            obj.GenInstruments([obj.varlist.market, obj.varlist.firm], obj.varlist.demand_iv_basis, 'demand_firm');
        [obj.var, obj.varlist.demand_rival_sum] = ...
            obj.GenInstruments(obj.varlist.market, obj.varlist.demand_iv_basis, 'demand_rival');
        [obj.var, obj.varlist.supply_firm_sum] = ...
            obj.GenInstruments([obj.varlist.market, obj.varlist.firm], obj.varlist.supply_iv_basis, 'supply_firm');
        [obj.var, obj.varlist.supply_rival_sum] = ...
            obj.GenInstruments(obj.varlist.market, obj.varlist.supply_iv_basis, 'supply_rival');
        
        obj.var = obj.GenInstruments({'year', 'firm_id'}, 'const', 'ncar_firm');
        for type = {'demand', 'supply'}
            for var = obj.varlist.([type{:}, '_iv_basis'])
                iv_var_name = [type{:}, '_firm_', var{:}];
                obj.var.(iv_var_name) = obj.GetArray(var{:}) .* obj.var.ncar_firm_const;
            end
        end
    end
end

end