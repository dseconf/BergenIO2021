function test_get_sample_sensitivity

    addpath(genpath('../external/matlab'))
    addpath(genpath('../m'))
    rng(12345)

    % If ahat is zero, then sample sensitivity equals approximate
    % sensitivity.
    [nparam, nmom] = deal(6, 10);
    jacobian = rand(nmom,nparam);
    ahat     = zeros(nparam, nparam);
    sample = get_sample_sensitivity(jacobian, ahat, eye(nmom));
    approx = get_sensitivity(jacobian, eye(nmom));
    assertElementsAlmostEqual(sample, approx, 'absolute', 1E-6);

    % If ahat = Jacobian' * Weight * Jacobian, sample sensitivity is one
    % half of approximate sensitivity.
    [nparam, nmom] = deal(4, 5);
    jacobian = rand(nmom, nparam);
    weight = diag(1:nmom);
    ahat = jacobian' * weight * jacobian;
    sensitivity      = get_sensitivity(jacobian, weight);
    sample_sensitivity = get_sample_sensitivity(jacobian, ahat, weight);
    
    assertElementsAlmostEqual(sensitivity, 2*sample_sensitivity, 'absolute', 1E-6);

    % Checks standardized sensitivity
    ahat = rand(nparam);
    [s, standardized_s] = get_sample_sensitivity(jacobian, ahat, eye(nmom), ones(nparam, 1), ones(nmom, 1));
    assertElementsAlmostEqual(standardized_s, s, 'absolute', 1E-6);
end
