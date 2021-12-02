function expanded_array = expand_array(array, counts)
%
% Replicate each row of an array a specified number of times.
%
% Inputs:
%    array        Array whose rows will be replicated
%    counts       Column vector with length equal to the number of rows in array; row i of array
%                 will be replicated counts(i) times.
%

    if ~isequal(size(array,1), length(counts)) || ~isvector(counts)
        error('Inputs to expand_array must array and vector with same row dimension');
    end

    expanded_array = array( expand_indices(counts) , :);

end


function expanded_indices = expand_indices(countvec)
    rows = length(countvec);
    maxcount = max(countvec);
    indicator = repmat(countvec', maxcount, 1) >= repmat((1:maxcount)', 1, rows);
    values = repmat(1:rows, maxcount, 1);
    expanded_indices = values(find(indicator)); 
end
