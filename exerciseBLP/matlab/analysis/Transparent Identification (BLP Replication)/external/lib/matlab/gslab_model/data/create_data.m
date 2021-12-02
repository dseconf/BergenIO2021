% Create data for Matlab test scripts
rng(12345)
nobs = 10^5;
x1 = rand(1, nobs);
x2 = rand(1, nobs);
x3 = rand(1, nobs);
x4 = rand(1, nobs);

% Group variable
group = floor((((1:nobs)+1)/2));

% Normal random variable
rng('default')
y_norm = 10 + randn(1,nobs); 

% Create logit variable for test_against_stata
x1_logit = round(x1);

% Create logit variable which is highly correlated within clusters
xclust1 = rand(1,floor(nobs/2));
xclust2 = mod(xclust1+0.01, 1);
xclust_rounded = [round(xclust1); round(xclust2)];
xclust_logit = xclust_rounded(:)';

% Write to CSV
X = [x1; x2; x3; x4; group; y_norm; x1_logit; xclust_logit];

header = 'x1,x2,x3,x4,group,y_norm,x1_logit,xclust_logit';
test_data = fopen('test_data.csv', 'w+');
fprintf(test_data, '%s\n', header);
fprintf(test_data, '%1.16f,%1.16f,%1.16f,%1.16f,%1.0f,%2.16f,%1.0f,%1.0f\n',X);
fclose(test_data);

exit;
