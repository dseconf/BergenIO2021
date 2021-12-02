function test_get_sensitivity

    addpath(genpath('../external/matlab'))
    rng(12345)

    % If jacobian is square, sensitivity is inverse of jacobian.
    [nparam, nmom] = deal(6, 6);
    jacobian = rand(nmom,nparam); 
    sensitivity1 = get_sensitivity(jacobian, eye(nmom));
    assertElementsAlmostEqual(sensitivity1, -inv(jacobian), 'absolute', 1E-8);

    % If jacobian is square, weight matrix does not affect sensitivity.
    sensitivity2 = get_sensitivity(jacobian, rand(nmom));
    diff = sensitivity1 - sensitivity2;
    assertElementsAlmostEqual(diff, zeros(nparam, nmom), 'absolute', 1E-8);

    % If jacobian is not square, weight matrix does affect sensitivity.    
    [nparam, nmom] = deal(4, 6);
    jacobian = rand(nmom,nparam); 
    sensitivity1 = get_sensitivity(jacobian, eye(nmom));
    sensitivity2 = get_sensitivity(jacobian, rand(nmom));
    issame = double(sensitivity1 == sensitivity2);
    assertElementsAlmostEqual(issame, zeros(nparam, nmom), 'absolute', 1E-8);

    % Checks standardized sensitivity
    [s standardized_s] = get_sensitivity(jacobian, eye(nmom), ones(nparam, 1), ones(nmom, 1));
    assertElementsAlmostEqual(standardized_s, s, 'absolute', 1E-8);
end
