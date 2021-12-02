function bool = IsValidModel(obj)
%
% Determines whether a particular implementation of MdeModel is valid
%

bool = true;

% all lists are cell arrays of strings that are either empty or row arrays
for listname = {'paramlist'}
    list = obj.(listname{:});
    bool = bool && iscellstr(list) && (isempty(list) || size(list,1)==1);
end
