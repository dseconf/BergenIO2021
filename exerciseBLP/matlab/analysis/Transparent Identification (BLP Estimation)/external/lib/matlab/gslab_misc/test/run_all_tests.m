diary off
diary '../log/test.log'
clear
clear global

addpath(genpath('../external/matlab_xunit'))
addpath(genpath('../m'))

runtests -verbose

diary off
exit
