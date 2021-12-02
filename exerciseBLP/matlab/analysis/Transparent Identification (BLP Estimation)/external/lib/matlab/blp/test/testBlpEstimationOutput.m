function testBlpEstimationOutput
%
% Unit tests for BlpEstimationOutput class
%

addpath(genpath(fullfile(fileparts(pwd), 'external')))
addpath(genpath(fullfile(fileparts(pwd), 'depend')))
addpath(genpath(fullfile(fileparts(pwd), 'm')))

% Setup
data = BlpData('blp_1999_data.csv', 'meanincome.csv', 'sdincome.csv', 'unobs_pub.csv');

model = BlpModel();
model.delta_tol = 1e-5;    % Decreases delta_tol for faster runtime and to match BLP (1999) code
model = model.LoadStartParam('published_param.csv');
model = model.SetupInstruments({}, data, 0.99);

wmatrix = eye(length(model.iv_varnames));

estopts = BlpEstimationOptions();
estopts.ktr = optimset(estopts.ktr, 'MaxIter', 1);

est = model.Estimate(data, wmatrix, estopts);
est.Play();


% Tests post-estimation ComputeElasticity method
for varname = model.demand_varlist;
    varname = varname{:};
    elasticity = est.ComputeAttributeElasticity(data, varname);
    disp(['Mean and SD of ', varname, ' elasticity:']);
    disp([mean(elasticity), std(elasticity)]);
end
elasticity = est.ComputePriceElasticity(data);
disp('Mean and SD of price elasticity:');
disp([mean(elasticity), std(elasticity)]);


% Compares with GAUSS output from BLP (1999) code
file_contents = importdata('published_param.csv');
param_names = file_contents.textdata(2:end, 1);
loaded_param = file_contents.data(:, 1);
relevant_indices = ismember(param_names, model.beta_paramlist);

published_beta = loaded_param(relevant_indices);
published_param = model.default_startparam;

elasticity = zeros(data.nobs, length(model.demand_varlist) + 1);
for i = 1:length(model.demand_varlist)
    varname = model.demand_varlist{i};
    elasticity(:, i) = est.ComputeAttributeElasticity(data, varname, published_param, published_beta);
end
elasticity(:, end) = est.ComputePriceElasticity(data, published_param);

sample_year = 90;
elasticity_year = elasticity(data.GetArray(data.varlist.market) == sample_year, :);

translate_99_to_95 = [1 2 4 5 3];
blp_1999_attribute_elasticity = importdata('attribute_elasticity.csv', ',');
blp_1999_price_elasticity = importdata('price_elasticity.csv', ',');
blp_1999_elasticity = [blp_1999_attribute_elasticity.data(:, translate_99_to_95), ...
                       blp_1999_price_elasticity.data];

assertElementsAlmostEqual(elasticity_year, blp_1999_elasticity, 'absolute', 10^-3);


% Displays elasticities of 1990 car sample from BLP (1995) paper
% Note that here we use a version of the model with
% fewer solver iterations rather than the full model
car_sample = [69 91 43 25 54 48 11 89 2 68 22 65 10];    % See BLP (1999) code, base.prg, line 940 (note change in order)
elasticity_sample = elasticity_year(car_sample, :);
disp('Elasticities of 1990 sample presented in BLP (1995) table V:');
disp(elasticity_sample(:, 2:end));

end