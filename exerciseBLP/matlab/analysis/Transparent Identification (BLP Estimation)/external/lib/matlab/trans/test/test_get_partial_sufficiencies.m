function test_get_partial_sufficiency

    addpath(genpath('../external/matlab'))
    estopts = MleEstimationOptions('quiet', 1);
   
    data = MleData('File', '../external/data/test_data.csv', 'format', '%f%f%f%f%f%f%f%f', ...
                  'Delimiter', ',', 'ReadVarNames', true);
    data.var = data.var(1:10^5,:); 
    regmodel = LinearRegressionModel('y', {'x1','x2'});
    regtrueparam = [-1; 3; 0.5; 2];

    rng(12345)
    simdata = regmodel.Simulate(regtrueparam, data);
    est = regmodel.Estimate(simdata, estopts);
    influence_function = est.InfluenceFunction();
    sensitivity = est.ComputeSensitivity(influence_function).unstandardized;
    sufficiency = get_sufficiency(sensitivity, est.se, est.vcov);

    paramlist = {'x1'; 'x2'};
    momlist   = {'m1'; 'm2'};
    
    % Test key_mom input as strings
    key_mom   = {'m1'; 'm1 m2'};
    
    partial_sufficiencies = get_partial_sufficiencies(paramlist, momlist, key_mom, ...
                                                      sensitivity, est.se, est.vcov);
    
    assertElementsAlmostEqual(partial_sufficiencies(1), sufficiency(1), 'absolute', 10^-8);
    assertElementsAlmostEqual(partial_sufficiencies(2), 1, 'absolute', 10^-8);
    
    % Test key_mom input as cells
    key_mom   = {{'m1'}; {'m1', 'm2'}};
    
    partial_sufficiencies = get_partial_sufficiencies(paramlist, momlist, key_mom, ...
                                                      sensitivity, est.se, est.vcov);
    
    assertElementsAlmostEqual(partial_sufficiencies(1), sufficiency(1), 'absolute', 10^-8);
    assertElementsAlmostEqual(partial_sufficiencies(2), 1, 'absolute', 10^-8);
end
