function testBlpData
%
% Unit tests for BlpData class and subclasses
%

addpath(genpath(fullfile(fileparts(pwd), 'external'))) 
addpath(genpath(fullfile(fileparts(pwd), 'depend'))) 
addpath(genpath(fullfile(fileparts(pwd), 'm'))) 

data = setup();
testAddIncomeParams(data);
testGenInstruments();
testRemoveCollinearity(data);
testDataAgainstPublished(data);
testBlp1995ErroneousData(data);
data_bootstrap = BlpData('blp_1999_data.csv', 'meanincome.csv', 'sdincome.csv', 'unobs_guess_bootstrap.csv');
testDrawBootstrapSamples(data_bootstrap);

function data = setup()
    data = BlpData('blp_1999_data.csv', 'meanincome.csv', 'sdincome.csv', 'unobs_guess.csv');

    summary(data.var);
    disp('Means of characteristic unobservables');
    disp(mean(data.unobs, 1));
    disp('Mean of income unobservables');
    disp(mean(data.unobs_income));
    disp('Means for individual income draws across years');
    disp(mean(data.income, 1'));
    disp('Overall mean for income draws');
    disp(mean(mean(data.income)));
end

function testAddIncomeParams(data)
    assert(length(unique(data.var.log_income_mean)) == data.nmarkets);
    assert(isfield(data.const, 'log_income_sd'));
end

function testGenInstruments()
    test_iv_varnames = {'year', 'firm_id', 'x', 'true_firm_sum_x', 'true_rival_sum_x'}';
    test_iv_var = [1 1 1 5 9; ...
                   1 1 2 4 9; ...
                   1 1 3 3 9; ...
                   1 2 4 0 11; ...
                   1 3 5 0 10; ...
                   2 1 6 0 0];
    test_iv_data = data;
    test_iv_data.var = dataset([{test_iv_var}, test_iv_varnames']);

    [test_iv_data.var, test_iv_data.varlist.firm_sum] = ...
        test_iv_data.GenInstruments({'year', 'firm_id'}, {'x'}, 'firm_sum', {'x'});
    [test_iv_data.var, test_iv_data.varlist.rival_sum] = ...
        test_iv_data.GenInstruments({'year'}, {'x'}, 'rival_sum', {{'x'}, test_iv_data.varlist.firm_sum});

    assert(all(test_iv_data.var.true_firm_sum_x == double(test_iv_data.var(:, test_iv_data.varlist.firm_sum))));
    assert(all(test_iv_data.var.true_rival_sum_x == double(test_iv_data.var(:, test_iv_data.varlist.rival_sum))));
end

function testRemoveCollinearity(data)
    for var = [data.varlist.demand_firm_sum, data.varlist.demand_rival_sum]
        data = data.RemoveData(var{:});
    end
    [data.var, data.varlist.demand_firm_sum] = ...
        data.GenInstruments([data.varlist.market, data.varlist.firm], data.varlist.demand_iv_basis, 'demand_firm');
    [data.var, data.varlist.demand_rival_sum] = ...
        data.GenInstruments(data.varlist.market, data.varlist.demand_iv_basis, 'demand_rival');
    
    % Tests RemoveCollinearity using output from GAUSS 'uncollin' procedure
    demand_varlist = {'const', 'hpwt', 'air', 'mpd', 'space'};
    demand_iv_varlist = [demand_varlist, strcat('demand_firm_', demand_varlist), ...
        strcat('demand_rival_', demand_varlist)];    % Note order is important
    matrix = data.GetArray(demand_iv_varlist);
    [~, r2] = BlpData.RemoveCollinearity(matrix, 0.99);
    gauss_r2 = [0.000000000000, 0.106372933526, 0.018951344877, 0.401449145779, ...
                0.184073841033, 0.970697272743, 0.653694677863, 0.936459507747, ...
                0.995007939916, 0.585807426637, 0.949424475924, 0.935587558595, ...
                0.956388311732, 0.985293446641]';
    assertElementsAlmostEqual(r2(2:end), gauss_r2, 'absolute', 1e-10);
end

function testDataAgainstPublished(data)
    % Tests data against published OLS logit results (Table III, column 1)
    ols_coefs_pub = [-10.068 -0.121 -0.035 0.263 2.341 -0.089]';

    ols_depvar = data.GetArray(data.varlist.logit_depvar);
    ols_regressors = data.GetArray({'const', 'hpwt', 'air', 'mpd', 'space', 'price'});
    ols_coefs_est = regress(ols_depvar, ols_regressors);

    assertElementsAlmostEqual(ols_coefs_pub, ols_coefs_est, 'absolute', 10^-2);
end

function testBlp1995ErroneousData(data)
    error_data = Blp1995ErroneousData('blp_1999_data.csv', 'meanincome.csv', 'sdincome.csv');
    
    firm_sum_varlist = [data.varlist.demand_firm_sum, data.varlist.supply_firm_sum];
    assert(~all(all(data.GetArray(firm_sum_varlist) == error_data.GetArray(firm_sum_varlist))));
end

function testDrawBootstrapSamples(data)
    unobs_per_market = 10;
    bootsample_cell = data.DrawBootstrapSamples(10, unobs_per_market);
    for i = 1:length(bootsample_cell)
        assert(bootsample_cell{i}.nmarkets==data.nmarkets);
        assert(length(unique(bootsample_cell{i}.market_levels))==length(data.market_levels));
        % Test if unobservable vector is correctly drawn based on market
        boot_first_market_unobs_year = bootsample_cell{i}.unobs_year(1:unobs_per_market);
        assert(all(ismember(boot_first_market_unobs_year, boot_first_market_unobs_year(1))));
        boot_first_market_unobs = bootsample_cell{i}.unobs(1:unobs_per_market, :);
        data_first_market_unobs = data.unobs(data.unobs_year == boot_first_market_unobs_year(1), :);
        assert(all(all(boot_first_market_unobs == data_first_market_unobs(1:unobs_per_market, :))));
    end 
end
end