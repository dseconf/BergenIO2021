function testMdeModel
%
% Tests against Stata output
%
    addpath(genpath(fullfile(fileparts(fileparts(pwd)), 'external'))) 
    addpath(genpath(fullfile(fileparts(fileparts(pwd)), 'depend'))) 
    addpath(genpath(fullfile(fileparts(fileparts(pwd)), 'm'))) 
    addpath(genpath(fileparts(fileparts(pwd)))) 
    rng(12345)
    estopts = MdeEstimationOptions();
    estopts.ktr = optimset(estopts.ktr, 'TolX', 1E-20, 'TolFun', 1E-10);

    data = MdeData('File', '../external/data/test_data.csv', 'format', '%f%f%f%f%f%f%f%f', 'Delimiter', ',', 'ReadVarNames', true);
    data.var = data.var(1:100,:);
    
    % Linear GMM
    model = LinearGMMModel('y_norm', {'x1','x2'});  
    wmatrix = unadjusted_wmatrix(data, model);
    est = model.Estimate(data, wmatrix, estopts);
    
    assertElementsAlmostEqual(est.param', load('parammat_stataout_linear.txt'), 'absolute', 10^-4);
    assertElementsAlmostEqual(est.vcov, load('vcovmat_stataout_linear.txt'), 'absolute', 10^-4);

    % Check Sum
    write_checksum('../log/checksum.log','MdeModel.m', est.param, est.vcov)

    % Linear GMM with instruments
    model = LinearGMMModel('y_norm', {'x1'}, {'x3','x4'});    
    wmatrix = unadjusted_wmatrix(data, model);
    est = model.Estimate(data, wmatrix, estopts);

    stata_param = load('parammat_stataout_linear_instr.txt');
    stata_obj = wtd_dist(model, stata_param', data, wmatrix);
    gslab_mde_obj = wtd_dist(model, est.param, data, wmatrix);
    assertElementsAlmostEqual(gslab_mde_obj, stata_obj, 'relative', 10^-10);
    assertElementsAlmostEqual(wmatrix, load('wmat_stataout_linear_instr.txt'), 'absolute', 10^-4);
    assertElementsAlmostEqual(est.param', load('parammat_stataout_linear_instr.txt'), 'absolute', 10^-4);
    assertElementsAlmostEqual(est.vcov, load('vcovmat_stataout_linear_instr.txt'), 'absolute', 10^-4);
 
    % Check Sum
    write_checksum('../log/checksum.log','MdeModel.m', est.param, est.vcov)

    cleanup()
end

function wmatrix = unadjusted_wmatrix(data, model)
    z = data.GetArray(model.instrlist);
    z = [z ones(data.nobs,1)];
    wmatrix = data.nobs * inv(z' * z);
end

function q = wtd_dist(model, param, data, wmatrix)
    g = model.ComputeDistanceVector(param, data);
    q = g' * wmatrix * g; 
end

function [] = cleanup()
    delete('parammat_stataout_linear.txt', 'vcovmat_stataout_linear.txt', ... 
           'parammat_stataout_linear_instr.txt', 'vcovmat_stataout_linear_instr.txt', ...
           'wmat_stataout_linear_instr.txt');
end


