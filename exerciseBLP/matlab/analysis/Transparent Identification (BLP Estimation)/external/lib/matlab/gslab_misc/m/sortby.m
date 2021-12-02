function [sorted_array sorted_vector] = sortby(array, vector)
%
% Sort the rows of an array according to a vector.
%
% Inputs:
%    array       n x k array
%    vector      n x 1 vector
%

    if ~isvector(vector) || length(vector) ~= size(array,1)
        error('Inputs to sortby must be an array and vector with same row dimension');
    end

    m = sortrows([vector array], 1);
    sorted_vector = m(:,1);
    sorted_array = m(:,2:end);

end

