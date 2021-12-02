function summarize_vector( vector )
%SUMMARIZE_VECTOR Displays summary statistics for contents of a vector

assert(is_vector(vector));

statnames = {'min', 'mean', 'std', 'max', 'length'};
stats = {min(vector), mean(vector), std(vector), max(vector), length(vector)};
plist = [1 5 10 25 50 75 90 95 99];
p = prctile(vector, plist);

disp(' ');
disp('Percentiles');
disp('----------');
for i=1:length(plist)
    fprintf('%2.0f   %g\n', [plist(i) p(i)]);
end

disp(' ');
disp('Statistics');
disp('----------');
fprintf('%s     %g\n', 'min', min(vector));
fprintf('%s    %g\n', 'mean', mean(vector));
fprintf('%s     %g\n', 'std', std(vector));
fprintf('%s     %g\n', 'max', max(vector));
fprintf('%s  %g\n', 'length', length(vector));

end

function isvector = is_vector (array)
    isvector = 1;
    isvector = isvector & (ndims(array)==2);
    isvector = isvector & (size(array, 1)==1|size(array, 2)==1);
end
    

