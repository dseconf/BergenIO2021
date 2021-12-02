% Matthew Gentzkow
% June 24, 2002
%
% findinmat
% 
% Return the index of the first row in a matrix that matches an input vector.  

function index = findinmat(row,mat)

totrows = size(mat,1);
match = 0;
j = 1;
while match == 0
    if row==mat(j,:) 
        index=j;
        match=1;
    elseif j==totrows
        index=-1;
        match=1;
    else 
        j = j+1;
    end
end