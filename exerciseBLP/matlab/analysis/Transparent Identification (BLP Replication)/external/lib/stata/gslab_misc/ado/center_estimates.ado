version 13
cap program drop center_estimates

program define center_estimates, rclass
    syntax anything
    
    preserve
    tempname COEF
    tempname TABLE
    matrix `COEF' = e(b)
    
    quietly fvexpand `anything'
    local anything = r(varlist)
    gen relevant_sample = 0
    foreach name in `anything' {
        if colnumb(`COEF', "`name'") == . {
            disp as error "ERROR: `name' not found in coefficient names."
            error -1
        }
        local level = regexr("`name'", "[a-zA-Z]*\..*", "")
        local varname = regexr("`name'", ".*\.", "")
        quietly replace relevant_sample = 1 if (`varname' == `level') & e(sample)
        quietly count if `varname' == `level' & relevant_sample
        matrix `TABLE' = nullmat(`TABLE') \ (`COEF'[1, "`name'"] , r(N))
    }
    quietly summarize `e(depvar)' if relevant_sample, meanonly
    local center_target_mean = r(mean)
    
    matrix colnames `TABLE' = b num_obs
    clear
    quietly svmat `TABLE', names(col)
    
    quietly summarize b [fw=num_obs], meanonly
    local weighted_b_mean = r(mean)
    
    return local target_mean = `center_target_mean'
    return local weighted_b_mean = `weighted_b_mean'
    return local diff_to_mean = `center_target_mean' - `weighted_b_mean'
end
