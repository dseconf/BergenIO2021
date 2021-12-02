function test_columnplot
%
% Unit test for columnplot function
%
rng(12345)
nobs = 100;
x = round(rand(100,100));
x = x + round(rand(100,100));
x(:,11:20) = zeros(100,10);
x(:,21:25) = NaN(100,5);
x(11:20,:) = zeros(10,100);
x(21:25,:) = NaN(5,100);
group = floor((((1:nobs)+1)/10))';
grouporder = [2;4;8;9];
columngroup = randsample(1:3, 100, 'true');
columngrouporder = [3;2];
colorgroup = randsample(1:2, 100, 'true');
colorlist{1} = [1 0 0];
colorlist{2} = [0 0 1];

% Good cases
columnplot(x);
columnplot(x, [], [], [], [], [], 'columndrop');
columnplot(x, [], [], [], [], [], 'rowdrop');
columnplot(x, group, grouporder);
columnplot(x, group, grouporder, [], [], [], 'columndrop', 'rowdrop');
columnplot(x, [], [], columngroup, columngrouporder);
columnplot(x, [], [], columngroup, columngrouporder, [], 'columndrop', 'rowdrop');
columnplot(x, group, grouporder, columngroup, columngrouporder, [], 'rowdrop', 'columndrop');
columnplot(x, group, grouporder, columngroup, columngrouporder, colorlist);
columnplot(x, group, grouporder, columngroup, columngrouporder, colorlist, 'rowdrop', 'columndrop');
