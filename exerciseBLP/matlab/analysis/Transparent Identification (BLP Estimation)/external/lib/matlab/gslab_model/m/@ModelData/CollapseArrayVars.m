function obj = CollapseArrayVars(obj)
%
% Collapses variables of the form [varname]_array_[ind1]_[ind2]
%
% INPUTS
%
%
% OUTPUTS
%
%    - obj: ModelData object, with all variables of the form [varname]_array_[ind1]_[ind2] collapsed
%           into double arrays [varname] with dimension max(ind1) by max(ind2). 
%

varnames = obj.var.Properties.VarNames;
nobs = size(obj.var, 1);
dataout = dataset();

for i = 1:length(varnames)
    foundarray = regexp(varnames{i}, '_array_[0-9]*_[0-9]');
    if isempty(foundarray)
        dataout.(varnames{i}) = obj.var.(varnames{i});
    elseif foundarray
        arrayname = varnames{i}(1:(foundarray-1));
        lastarrayvar = find(~cellfun('isempty',regexp(varnames,strcat('^', arrayname, ...
            '(?=_array_[0-9]*_[0-9])'))), 1, 'last');
        dimstring = varnames{lastarrayvar}((foundarray+length('_array_')):end);
        dimnums = cellfun(@str2num, regexp(dimstring, '([0-9]*)','match'));
        nrow = dimnums(1);
        ncol = dimnums(2);
        arrayvar = zeros(nobs, nrow, ncol);
        for r = 1:nrow
            for c = 1:ncol
                arrayvar(:,r,c) = obj.var.(strcat(arrayname, '_array_', num2str(r), '_', num2str(c)));
            end
        end
        dataout.(arrayname) = double(arrayvar);
    end
end
obj.var = dataout;
end    
