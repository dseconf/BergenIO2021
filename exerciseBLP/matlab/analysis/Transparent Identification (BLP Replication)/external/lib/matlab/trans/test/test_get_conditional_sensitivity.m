function test_get_conditional_sensitivity

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
    [ cs st_cs ] = get_conditional_sensitivity(ones(3,5), eye(3), eye(5), [1,3]);
    assertElementsAlmostEqual(size(cs), [2 5], 'absolute', 10^-8);
    assertElementsAlmostEqual(size(st_cs), [2 5], 'absolute', 10^-8);
    
    [ cs st_cs ] = get_conditional_sensitivity(sensitivity, est.vcov, est.vcov, 1:size(est.vcov,1));
    assertElementsAlmostEqual(cs, sensitivity, 'absolute', 10^-8);
    assertElementsAlmostEqual(st_cs, sensitivity, 'absolute', 10^-8);
    
    % Create test data
    rng(12345)
    a = rand(6);
    vcov = a'*a;
    data = mvnrnd(zeros(6,1), vcov, 10^5);
    
    % Confirm sensitivity calculations
    Sigma = cov(data);
    sensitivity = Sigma(1:3,4:6) / Sigma(4:6,4:6);
    r1 = regress(data(:,1), data(:,4:6));
    s1 = get_conditional_sensitivity(sensitivity, Sigma(1:3,1:3), Sigma(4:6,4:6), 1:3);
    assertElementsAlmostEqual(r1', s1(1,:), 'absolute', 10^-4);

    r2 = regress(data(:,1), data(:,[2 4:6]));
    s2 = get_conditional_sensitivity(sensitivity, Sigma(1:3,1:3), Sigma(4:6,4:6), [1 3]);
    assertElementsAlmostEqual(r2(2:end)', s2(1,:), 'absolute', 10^-4);
end
