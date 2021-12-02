function testExampleModel
%
% Tests ExampleModel tests the instantiations of ExampleModel, EstimationOptions, and EstimationOutputs
% 
    addpath(genpath(fullfile(fileparts(fileparts(pwd)), 'external'))) 
    addpath(genpath(fullfile(fileparts(fileparts(pwd)), 'depend'))) 
    addpath(genpath(fullfile(fileparts(fileparts(pwd)), 'm'))) 
    rng(12345)

    % Tests ExampleModel instantiation and AddCoefficients
    model = ExampleModel('y', {'x'});
    assertEqual(char(model.paramlist(1)), 'constant');
    assertEqual(char(model.paramlist(2)), 'x_coeff');
    assertEqual(model.lhslist, 'y');
    assertEqual(char(model.rhslist(1)), 'x');

    % A simple parameter estimation workflow
    data = ExampleData('File', '../data/test_data.csv', 'format', '%f%f%f%f%f%f%f%f', ...
                  'Delimiter', ',', 'ReadVarNames', true);
    estopts = ExampleEstimationOptions('quiet', 1);
    estopts.startparam = model.default_startparam;    
    est = model.Estimate(data, estopts);    
    
    % The following tests follow from the fact that the objective function
    % in ExampleModel.m is always minimized at zero. Furthermore, the 
    % standard errors from ExampleEstimationOutput are always one. 
    % Together they confirm that the above code work as expected. 
    assertElementsAlmostEqual(est.param, [0; 0], 'absolute', 10^-4) 
    assertElementsAlmostEqual(est.se, [1; 1], 'absolute', 10^-4) 
 end

