%Simulates data and runs analyses that we might expect from a highly computation Matlab script. 
%Logs output time as I/O, Paralleled, or Serial.
%
%parallel code loops in parfor.
%serial code loops in for
%io writes a large file, then deletes it.

function [] = benchmark(cores)
try 
	evalc('matlabpool close');
catch 
end
evalc('matlabpool(cores)');

display('Running test code...')

obs = 1000000;
vars = 10;

data =  (100).*rand([obs, vars]);

%I/O
tic;
writeme(data)
io=toc;

%serial
tic;
forme(data)
serial = toc;

%parallel
tic;
parforme(data)
parallel=toc;

display(['I/O time: ', num2str(io), 's'])
display(['Serial time: ', num2str(serial), 's'])
display(['Parallel time: ', num2str(parallel), 's'])
display(['TOTAL: ', num2str(io + serial + parallel), 's'])

evalc('matlabpool close');

function [] = forme(data)
	for i=1:100
		spdiags(1./sum(data,2),0,size(data,1),size(data,1))*data;
	end
	
function [] = parforme(data)
	parfor i=1:1000
		spdiags(1./sum(data,2),0,size(data,1),size(data,1))*data;
	end

function [] = writeme(data)
	dlmwrite('tempfile.txt', data(1:10000,:), 'delimiter', '\t', 'precision', '3')
	delete 'tempfile.txt'

	