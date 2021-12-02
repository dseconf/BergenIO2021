function testBlpModel
%
% Unit tests for BlpModel class
%

addpath(genpath(fullfile(fileparts(pwd), 'external')))
addpath(genpath(fullfile(fileparts(pwd), 'depend')))
addpath(genpath(fullfile(fileparts(pwd), 'm')))

% Tests BlpModel class
data = BlpData('blp_1999_data.csv', 'meanincome.csv', 'sdincome.csv', 'unobs_pub.csv');

model = BlpModel();
model.delta_tol = 1e-5;    % Decreases delta_tol for faster runtime and to match BLP (1999) code
model = model.LoadStartParam('published_param.csv');
model = model.SetupInstruments({}, data, 0.99);

wmatrix = eye(length(model.iv_varnames));

estopts = BlpEstimationOptions();
estopts.lower_bound = [0 0 0 0 0 -Inf];    % Constrains sigma parameters to be positive
estopts.ktr = optimset(estopts.ktr, 'MaxIter', 2);

est = model.Estimate(data, wmatrix, estopts);

est.Play();


% Compares with GAUSS output from BLP (1999) code
data = BlpData('blp_1999_data.csv', 'meanincome.csv', 'sdincome.csv', 'unobs_guess.csv');

model = model.LoadStartParam('blp1999_guess_param.csv');
guess_param = model.default_startparam;
model = model.SetupInstruments({}, data, 0.9999, true);

demand_iv_var = data.GetArray(model.demand_iv_varlist);
supply_iv_var = data.GetArray(model.supply_iv_varlist);
z = blkdiag(demand_iv_var, supply_iv_var);

wmatrix = eye(length(model.iv_varnames));
bias_correction = zeros([length(z(:, 1)), 1]);
proj_z = z*wmatrix*z';    % Pre-computes projection matrix to save time
[~, ~, g_car] = model.ComputeDistanceVector(data, guess_param, proj_z, bias_correction);
wmatrix = inv(cov(g_car));
proj_z = z*wmatrix*z';

[~, ~, g_car, beta] = model.ComputeDistanceVector(data, guess_param, proj_z, bias_correction);
g = sum(g_car, 1)' / data.nobs;
obj = g'*wmatrix*g;

blp_1999_obj = importdata('objective.csv');
blp_1999_obj = blp_1999_obj.data;

assertElementsAlmostEqual(obj, blp_1999_obj, 'absolute', 10^-4);

% ahat should be symmetric
assertElementsAlmostEqual(est.ahat', est.ahat, 'absolute', 10^-4);
                   
end
