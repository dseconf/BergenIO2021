function run_all_tests

echo on
diary '../log/test.log'

addpath(genpath('../external/matlab_xunit'))
addpath(genpath('../depend/gslab_misc'))
addpath(genpath('../m'))

runtests

exit
