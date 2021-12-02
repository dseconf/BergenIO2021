function run_all_tests

addpath(genpath(fullfile(fileparts(pwd), 'external'))) 
addpath(genpath(fullfile(fileparts(pwd), 'depend'))) 
addpath(genpath(fullfile(fileparts(pwd), 'm'))) 

runtests . -verbose -logfile ../log/test.log

exit
