function testModelData
%
% Unit test for ExampleData class
%
    addpath(genpath(fullfile(fileparts(fileparts(pwd)), 'external'))) 
    addpath(genpath(fullfile(fileparts(fileparts(pwd)), 'depend'))) 
    addpath(genpath(fullfile(fileparts(fileparts(pwd)), 'm'))) 

    % Set up data
    data = ExampleData('File', '../data/test_data.csv', 'format', '%f%f%f%f%f%f%f%f', ...
                  'Delimiter', ',', 'ReadVarNames', true);
	data.var = data.var(1:10,:);
    x1 = (0:0.1:0.9)';
    x2 = data.var.x1;
    x3 = data.var.x2;
    rhs.x1 = x1;
    rhs.x2 = x2;
    lhs.y = [zeros(5,1); ones(5,1)];
    unobs.epsilon0 = data.var.x3;
    unobs.epsilon1 = data.var.x4;
    strvar = {'a';'b';'c'};
    group = [1;1;2;2;2;3;3;4;5;6];
    group2 = [1;1;1;1;1;2;2;2;2;2];
    badgroup1 = [1;1;2;2;2;3;3;4;6;5];
    badgroup2 = [1;1;2;2;2;3;3];

    % Basic data creation
    ExampleData(x1, x2);
    ExampleData(rhs);
    ExampleData(x1, x2, lhs);
    data = ExampleData(strvar);
    assert(data.nobs == 3);
    data = ExampleData(rhs, lhs, unobs);
    assert(data.nobs == 10);
    data = data.AddData(x1);
    assert(data.nvars==6);
    data = data.AddData(x3);
    assert(data.nvars==7);
    data = data.RemoveData('x1');
    assert(data.nvars==6);
    data = data.AddData(x1);
	
    % Groups
    data.groupvar = group;
    assert(data.nvars==7);
    assert(data.ngroups==6);
    data.groupvar = group2;
    assert(data.ngroups==2);
    assertbad('data.groupvar = badgroup1');
    assertbad('data.groupvar = badgroup2');

    % Indexing
    data.Select([1;3;5;7],:);
    data.Select(1:5,2);
    data.Select(6:7,'x1');
    newdata = data.Select(1:4,:);
    assert(newdata.nobs==4);

    % Bad cases
    assertbad('ExampleData(strvar, x1)')
    assertbad('ExampleData(x1, x2, rhs)')
    assertbad('ExampleData(1, 5)')
    assertbad('ExampleData(1, 5)')
	
	% Checksum
    write_checksum('../log/checksum.log','ExampleData.m',...
        [data.var.x1 data.var.x2 data.var.y data.var.epsilon0 data.var.epsilon1], newdata.var.x1)
	
	% Data creation using dataset() constructor arguments
	data1 = ExampleData('File', '../data/test_data.csv', 'format', '%f%f%f%f%f%f%f', ...
	   	   'Delimiter', ',', 'ReadVarNames', true);
	assert(data1.nvars==8);
	
	% Bad cases: dataset() constructor arguments that can't be passed through
	dataset(x1, x2, 'VarNames', {'a', 'b'});
	assertbad('ExampleData(x1, x2, ''VarNames'', {''a'', ''b''})');
	names = {'a','b','c','d','e','f','g','h','i','j'};
	dataset(x1, x2, 'ObsNames', names);
	assertbad('ExampleData(x1, x2, ''ObsNames'', names)');
	cellarg = {[x1, x2, x3], 'a', 'b', 'c'};
	data1 = dataset(cellarg);
	assertEqual(size(data1),[10, 3]);
	data1 = ExampleData(cellarg);
	% Note that if arguments are passed through, navrs here should be 4 since ExampleData creates addional variable obsindex
	assert(data1.nvars~=4);
	
	% Methods of dataset objects - these should all work on data.var (where data is an ExampleData object)
	data1 = ExampleData(x1, x2);
	data2 = ExampleData(x1, x2);
	data12 = horzcat(data1.var, data2.var);
	assertEqual(size(data12),[10, 3]);
	data1.var.Properties.VarNames = {'a', 'b', 'obsindex'};
	assert(data1.nvars==3);
	data12 = horzcat(data1.var, data2.var);
	assertEqual(size(data12),[10, 5]);
	data1 = replacedata(data1.var, ones(10,3));
	assertEqual(data1.a,ones(10,1));
	data1 = ExampleData(x1, group);
	widedata = unstack(data1.var, 'x1', 'group', 'NewDataVarNames', ...
					  {'x1', 'x2', 'x3', 'x4', 'x5', 'x6'});
	assertEqual(size(widedata),[10, 7]);   
end