%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% NumHess.m: Numerically computes the Hessian matrix
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hess] = NumHess(func,x0,xTol,varargin)
% This function computes the Hessian matrix.
%
% There are three required input arguments:
%   - "func" is a function handle for the function on which the Hessian is
%     to be computed. When "func" is empty, "hess" will be set to empty too.
%   - "x0" is the value for which the Hessian is to be evaluated at.
%   - "xTol" is the tolerance, where a small xTol corresponds to increased
%     accuracy of this numerical procedure.
%
% There are two optional input arguments, which are required to be
%     supplied together if either one is supplied:
%   - ind_rowvar
%   - ind_colvar
% When these two arguments are supplied, the function only computes part of
%     the Hessian matrix. If H is the full Hessian, then the output will be
%     equivalent to H(ind_rowvar, ind_colvar).
%
    if isempty(func)
        hess = [];
    else
        f0 = feval(func,x0);
        if ~isempty(varargin)
            assert(logical(sum(size(varargin)==[1,2])));
            ind_rowvar = varargin{1};
            ind_colvar = varargin{2};
        else
            ind_rowvar = 1:length(x0);
            ind_colvar = ind_rowvar;
        end
        hess = zeros(length(ind_rowvar),length(ind_colvar));
        
        for i=1:length(ind_rowvar)
            row = ind_rowvar(i);
            for j=1:length(ind_colvar)
                col = ind_colvar(j);
                increment_i = zeros(length(x0),1);
                increment_j = zeros(length(x0),1);

                increment_i(row) = max(x0(row)*xTol,xTol);
                increment_j(col) = max(x0(col)*xTol,xTol);
                increment_ij = increment_i+increment_j;
               
                f_i = feval(func,x0+increment_i);
                f_j = feval(func,x0+increment_j);
                f_ij = feval(func,x0+increment_ij);
               
                hess(i,j) = (f_ij+f0-f_i-f_j)/(increment_i(row)*increment_j(col));
            end
        end
    end
end