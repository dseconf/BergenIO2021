function test_make_vcov
    rng(123);

    num_tests = 20;
    max_diff = zeros(num_tests, 1);    
    mat_size = 15;
    eta = 10^-6;
    for i = 1:num_tests
        a = example_matrix(mat_size, eta);
        [~, p] = chol(a);
        assert(p > 0);

        [b, max_abs_diff, max_rel_diff] = make_vcov(a);
        max_diff(i) = max_abs_diff;
        
        assert(all(all(b == b')));
        [~, p] = chol(b);
        assert(p == 0);
    end
    assert(max(max_diff) < (eta * 10));
    
    load ./input/make_vcov_test_matrices.mat
    
    assert(symmetric(test_psd) & nonneg_eig(test_psd) & ~pos_def(test_psd));
    [test_psd_vcov, ~, ~, max_iter_reached] = make_vcov(test_psd);
    % iterations will not ensure symmetry
    assert(max_iter_reached);
    assert(~symmetric(test_psd_vcov));
    % algorithm will not make positive semi-definite matrix positive definite
    assert(nonneg_eig(test_psd_vcov) & ~pos_def(test_psd_vcov));

    assert(~symmetric(test_pd1) & ~pos_def(test_pd1));
    test_pd1_vcov = make_vcov(test_pd1);
    assert(symmetric(test_pd1_vcov) & pos_def(test_pd1_vcov));
    
    assert(~symmetric(test_pd2) & ~pos_def(test_pd2));
    test_pd2_vcov = make_vcov(test_pd2);
    assert(symmetric(test_pd2_vcov) & pos_def(test_pd2_vcov));
    
    test_pd2_vcov2 = make_vcov(test_pd2_vcov);
    assert(all(all(test_pd2_vcov == test_pd2_vcov2)));
end

function a = example_matrix(size, eta)
    a = rand(size);
    a = triu(a) + triu(a)';
    step = min(eig(a)) + eta;
    a = a - step * eye(size);
end

function bool = symmetric(in)
    bool = all(all(in == in'));
end

function bool = nonneg_eig(in)
    bool = min(eig(in)) >= 0;
end

function bool = pos_def(in)
    [~, p] = chol(in);
    bool = p == 0;
end