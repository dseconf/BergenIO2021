% Matthew Gentzkow
% June 24, 2002
%
% findr: Return the index / indices of one or more input rows in a given array.
%        If a row occurs more than once, the function returns the index of the first
%        occurrence.
% INPUTS
%   m       The array in which to look up the rows
%   r       The rows to look up. Must be an array with the same number of columns as
%           m. If r has a single row, findr returns a scalar giving the index
%           of the first row of m that matches r. If r is an array, it performs
%           this lookup for each row, returning the resulting indices as a vector.
%
% OUTPUTS
%   ind     The row indices in m that match r
%

function ind = findr(m,r)

% error checking
if size(r,2)~=size(m,2)
    error('Inputs to findr must have the same column dimension')
end
if size(unique(m,'rows'),1)<size(m,1)
    error('The first argument to findr must be an array with no duplicate rows')
end

cols=size(m,2);
sm=size(m,1);
sr=size(r,1);

r=repmat(reshape(r',[1 cols sr]),[sm 1 1]);
m=repmat(m,[1 1 sr]);
ind = squeeze(sum(m==r,2)==cols);

% handle case of row not found
if min(sum(ind,1))==0
    ind = [];
else
    % account for the fact that find does not operate column-wise
    ind = find(ind)-[0:sr-1]'*sm; 
end

end

