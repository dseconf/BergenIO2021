function test_get_sufficiency

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

    % Confirm dimensions
    get_sufficiency(ones(3,5), ones(3,1), eye(5), [1,3]);
    
    % Confirm if jacobian/se input is identical to obj.jacobian/se, 
    % sensitivity (unstandardized and standardized) is identity and sufficiency is 1
    sufficiency = get_sufficiency(sensitivity, est.se, est.vcov);
    assertElementsAlmostEqual(sufficiency, ones(size(sufficiency)), 'absolute', 10^-8);
    
    % confirm single row of lambda
    sufficiency_single_row = get_sufficiency(sensitivity(1,:), est.se(1), est.vcov, 1);
    assertElementsAlmostEqual(sufficiency(1), sufficiency_single_row, 'absolute', 10^-8);

end
