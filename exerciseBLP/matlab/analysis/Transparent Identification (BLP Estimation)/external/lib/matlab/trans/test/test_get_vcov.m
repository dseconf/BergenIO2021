function test_get_vcov
    matrices = {'jacobian', 'vcov_mom', 'weight', 'stata_vcov_param'};
    
    for m = matrices
        filename = strcat('./input/', m, '.csv');
        s.(m{:}) = csvread(filename{:});
    end
    
    get_vcov_param = get_vcov(s.jacobian, s.vcov_mom, s.weight);
                              
    assertElementsAlmostEqual(get_vcov_param, s.stata_vcov_param, 'relative', 10^-4);
end