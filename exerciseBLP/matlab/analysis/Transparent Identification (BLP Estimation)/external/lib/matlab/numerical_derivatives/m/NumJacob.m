function [jacobian] = NumJacob(func,x0,xTol)
    if isempty(func)
        jacobian = [];
    else
        f0 = feval(func,x0);
        nparam = length(x0);
        paramdim = size(x0);
        noutput = length(f0);
        jacobian = zeros(noutput,nparam);
        
        for j=1:nparam
            increment = zeros(paramdim);
            increment(j) = max(abs(x0(j))*xTol,xTol);
            x1 = x0+increment;
            f1 = feval(func,x1);
            jacobian(:,j) = (f1-f0)/increment(j);            
        end
    end

    
    
    
    