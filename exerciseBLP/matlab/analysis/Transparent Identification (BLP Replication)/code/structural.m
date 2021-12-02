function structural
    addpath(genpath('../external/'));
    
    data = BlpData('blp_1999_data.csv', 'meanincome.csv', 'sdincome.csv', 'unobs_pub.csv');
    load('blp_estimation')
    
    % Table IV (estimated parameters)
    ndemand = length(est.model.demand_varlist);
    nsupply = length(est.model.supply_varlist);
    % Reorders parameters to match BLP (1995) table ordering
    blp_1995_translate = [est.model.nparam + (1:ndemand), ...
                          1:est.model.nparam, ...
                          est.model.nparam + ndemand + (1:nsupply)];
    
    param = [est.param; est.beta];
    param_reordered = param(blp_1995_translate);
    
    vcov_param = get_vcov(est.gjacobian, est.Omega, est.wmatrix);
    se = sqrt(diag(vcov_param)) / sqrt(est.nmodels);
    se = se(blp_1995_translate);
    
    table = [param_reordered, se];
    
    fid = fopen('../output/tables.txt','a');
    fprintf(fid, '<Tab:blp_params>\n');
    dlmwrite('../output/tables.txt', table, '-append', 'delimiter', '\t', 'precision', '%.3f');
    
    % Table V (demand elasticities)
    % BLP's original data is sorted by car_id in 1990
    data_1990 = data.Select(data.var.year == 90, :);
    assert(issorted(data_1990.var.car_id));
    
    % See BLP (1999) code, base.prg, line 940
    blp_sample_1990_index = [22 25 11 43 48 68 2 10 69 54 65 91 89];
    blp_sample_car_id = data_1990.var.car_id(blp_sample_1990_index);
    blp_sample_index = find(ismember(data.var.car_id, blp_sample_car_id));
    
    sort_by_price = sortrows([blp_sample_index, data.var.price(blp_sample_index)], 2);
    blp_sample_index = sort_by_price(:, 1);
    
    demand_attributes = {'hpwt', 'air', 'mpd', 'space'};
    price_elasticity = est.ComputePriceElasticity(data, est.param);
    attribute_elasticity = zeros(est.nobs, length(demand_attributes));
    for i = 1:length(demand_attributes)
        attribute_elasticity(:, i) = ...
            est.ComputeAttributeElasticity(data, demand_attributes{i});
    end
    
    table = zeros(2 * length(blp_sample_index), 1 + length(demand_attributes));
    for i = 1:length(blp_sample_index)
        data_index = blp_sample_index(i);
        table(i * 2 - 1, :) = data.var(data_index, [demand_attributes, 'price']);
        table(i * 2, :) = [attribute_elasticity(data_index, :), ...
            price_elasticity(data_index)];
    end
    
    fprintf(fid, '<Tab:demand_elasticities>\n');
    dlmwrite('../output/tables.txt', table, '-append', 'delimiter', '\t', 'precision', '%.3f');
    
    % Table VIII (markups and variable profits)
    [~, mc] = est.model.ComputeModelOutputs(data, est.param);
    
    blp_sample_prices = data.var.price(blp_sample_index) * 1000;
    blp_sample_markup = blp_sample_prices - mc(blp_sample_index) * 1000;
    blp_sample_variable_profit = ...
        data.var.quantity(blp_sample_index) .* (blp_sample_markup);
    table = [blp_sample_prices, blp_sample_markup, blp_sample_variable_profit];
    
    fprintf(fid, '<Tab:markups_profits>\n');
    dlmwrite('../output/tables.txt', table, '-append', 'delimiter', '\t', 'precision', '%.0f');
    
    exit
end