function ahat = compute_ahat(jacob_func, x0, xTol, weight, g)
    jacobian  = feval(jacob_func, x0);
    ahat_rows = size(jacobian, 2);
    nparam    = length(x0);
    ahat      = zeros(ahat_rows, nparam);
    
    for p = 1:nparam
        % Compute the jacobian when paramater #p is slightly incremented
        increment     = max(xTol, xTol * x0(p));
        x1            = x0;
        x1(p)         = x1(p) + increment;
        jacobian_plus = feval(jacob_func, x1);

        % Derive Gp with respect to parameter #p and compute the pth column of ahat
        Gp         = (jacobian_plus - jacobian) / increment;
        ahat(:, p) = Gp' * weight * g;
    end
end
        
        