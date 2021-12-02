function bool = strfind_logical(cellstr, pattern)
% Searches for pattern in each element of the cell array of strings 'cellstr' and returns a logical
% array 'bool' with the same dimension as cellstr. A given element of the output is true if pattern 
% was found in the corresponding element of cellstr.

if ischar(cellstr)
    cellstr = {cellstr};
end
bool = false( size(cellstr) );
findarray = strfind(cellstr, pattern);
for i = 1:length(findarray(:))
    bool(i) = ~isempty( findarray{i} );
end