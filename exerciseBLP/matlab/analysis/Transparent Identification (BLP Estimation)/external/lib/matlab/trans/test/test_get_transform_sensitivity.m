function test_get_transform_sensitivity
    addpath(genpath('../external/matlab'))

    % Create test data
    rng(12345)
    a = rand(6);
    vcov = a'*a;
    data = mvnrnd(zeros(6,1), vcov, 10^5);

    Sigma = cov(data);
    sensitivity = Sigma(1:3,4:6) / Sigma(4:6,4:6);
    r = regress(data(:,1), data(:,4:6));
    stats = regstats(data(:,1), data(:,4:6), 'linear', 'rsquare');
    
    % test identity transform
    [t1, ~, t1suff, t1cov] = get_transform_sensitivity(sensitivity, eye(3), Sigma(1:3,1:3), Sigma(4:6,4:6));
    assertElementsAlmostEqual(r', t1(1,:), 'absolute', 10^-4);
    assertElementsAlmostEqual(stats.rsquare, t1suff(1), 'absolute', 10^-4);
    assertElementsAlmostEqual(Sigma(4:6,4:6), t1cov, 'absolute', 10^-4);
    
    % test very simple linear transform
    mult = 2;
    t2 = get_transform_sensitivity(sensitivity, eye(3) * mult, Sigma(1:3,1:3), Sigma(4:6,4:6));
    assertElementsAlmostEqual(r' / mult, t2(1,:), 'absolute', 10^-4);
    
    % test change of dimension
    transform_size = [1, 3];
    t3 = get_transform_sensitivity(sensitivity, repmat(1/3, transform_size), Sigma(1:3,1:3), Sigma(4:6,4:6));
    assert(all(size(t3') == transform_size))
end
