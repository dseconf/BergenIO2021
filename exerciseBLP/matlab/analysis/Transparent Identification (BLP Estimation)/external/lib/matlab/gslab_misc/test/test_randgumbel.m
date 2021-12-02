%
% Unit tests for rangumbel function
%
function test_suite = test_randgumbel
    initTestSuite;
end

% test 1: mean should be equal to Euler's constant,
%         which is equal to -psi(1)
function test_mean_value
    rng('default')
    test_scale = 100000;
    tol = 1e-2;
    assert( abs(mean(randgumbel([1,test_scale]))+psi(1)) < tol );
end

% test 2: variance should be equal to Pi^2/6
function test_variance
    rng('default')
    test_scale = 100000;
    tol = 1e-2;
    assert( abs(var(randgumbel([1,test_scale]))-pi^2/6) < tol );
end

% test 3: Simulating choices from a three-choice logit model should 
%         produces choice shares that match the following formula:
%         share_1 = exp(u_1) / (exp(u_1) + exp(u_2) + exp(u_3))
function test_choice_simulations
    rng('default')
    test_scale = 100000;
    tol = 1e-2;
    
    % initialize
    choice = zeros(1,test_scale);
    util_base = [1,2,3];
    share_sim = zeros(1,3);
    share_theory = zeros(1,3);

    % simulate choices
    for i=1:test_scale
        util = util_base + randgumbel([1,3]);
        choice(i) = find(util==max(util),1);
    end

    % compute shares
    for ind = 1:3
        share_sim(ind) = sum(choice==ind)/test_scale;
        share_theory(ind) = exp(ind)/sum( exp(util_base) );
    end

    assert( all( abs(share_sim-share_theory) < tol ) );
end