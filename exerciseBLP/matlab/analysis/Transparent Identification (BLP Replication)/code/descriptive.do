version 13
set more off
adopath + ../external/lib/stata/gslab_misc/ado
preliminaries

program main
    prepare_data
    table_1
    table_2
    table_3
end

program prepare_data
    insheet using ../external/data/blp_1999_data.csv, clear comma names double
    drop v19
    save ../temp/blp_data, replace
end

program table_1
    use ../temp/blp_data, clear
    replace year = year + 1900
    egen sum_share_year = total(share), by(year)
    gen weight = share / sum_share_year
    
    egen total_models = count(1)
    egen no_of_models = count(1), by(year)
    local total_no_models = total_models[1]
    quietly sum quantity
    local total_mean_quantity `r(mean)'
    foreach var of varlist price domestic japan european hpwt space air mpg mpd {
        egen sum_weighted_`var' = total(`var' * weight), by(year)
    }
    
    collapse (mean) no_of_models quantity sum_weighted_* (rawsum) sum_quantity_year=quantity, by(year)
    mkmat year no_of_models quantity sum_weighted_*, matrix(TABLE)
    matrix_to_txt, saving(../output/tables.txt) mat(TABLE) format(%20.3f) ///
        title(<tab:descriptive_statistics>) replace
    
    * Generate "All" row
    egen total_quantity = total(sum_quantity_year)
    gen weight = sum_quantity_year / total_quantity
    collapse (mean) sum_weighted_* [aw=weight]
    file open tables using ../output/tables.txt, write append
    file write tables  "All" _tab %7.3f (`total_no_models') _tab %7.3f (`total_mean_quantity') _tab 
    foreach var of varlist sum_weighted_* { 
        quietly sum `var'
        file write tables %7.3f (r(mean)) _tab
    }
    file write tables _n
    file close tables
end

program table_2
    use ../temp/blp_data, clear
    
    cap matrix drop TABLE
    replace mpg = mpg * 10    // mpg and mpd seem to enter table 2 as true mpg and mpd,
    replace mpd = mpd * 10    // but enter tables 1 and 3 in ten miles / gallon (or dollar)
    foreach var of varlist price quantity hpwt space mpd mpg {
        sum `var', detail
        matrix TABLE = nullmat(TABLE) \ (r(min), r(p25), r(p50), r(p75), r(max))
    }
    matrix_to_txt, saving(../output/tables.txt) mat(TABLE) format(%20.3f) ///
        title(<tab:demand_percentiles>) append
end

program table_3
    use ../temp/blp_data, clear
    cap matrix drop TABLE
    
    * Column 1 (OLS)
    reg logit_depvar hpwt air mpd space price
    compute_inelastic_demand, price_coef_name(price)
    local ols_inelastic_lower = round(r(ci_lower), 0.001)
    local ols_inelastic_upper = round(r(ci_upper), 0.001)
    matrix TABLE = _b[_cons]        \ _se[_cons]  \ ///
                   _b[hpwt]         \ _se[hpwt]   \ ///
                   _b[air]          \ _se[air]    \ ///
                   _b[mpd]          \ _se[mpd]    \ ///
                   .                \ .           \ ///
                   _b[space]        \ _se[space]  \ ///
                   .                \ .           \ ///
                   _b[price]        \ _se[price]  \ r(num_inelastic)
    scalar ols_r2 = e(r2)
    
    * Column 2 (IV)
    * First construct the instruments, following BLP (1995, p. 861)
    egen ncar_firm = count(1), by(year firm_id)
    local five_dmd_variables const hpwt air mpd space
    foreach var of local five_dmd_variables{ 
        * Reproduces IV construction from BLP (1995) code
        gen own_`var' = `var' * ncar_firm
        egen all_`var' = total(`var'), by(year)
    }
    
    local indep_var const hpwt air mpd space price
    local inst_var const hpwt air mpd space own_* all_*
    gmm (logit_depvar - {xb:`indep_var'}), ///
        instruments(`inst_var') ///
        winitial(identity) center
    compute_2sls_se, indep_var(`indep_var') inst_var(`inst_var')
    compute_inelastic_demand, price_coef_name(xb_price:_cons)
    local iv_inelastic_lower = round(r(ci_lower), 0.001)
    local iv_inelastic_upper = round(r(ci_upper), 0.001)
    matrix TABLE = nullmat(TABLE) ,                            ///
                   (_b[xb_const:_cons] \ _se[xb_const:_cons] \ ///
                   _b[xb_hpwt:_cons]   \ _se[xb_hpwt:_cons]  \ ///
                   _b[xb_air:_cons]    \ _se[xb_air:_cons]   \ ///
                   _b[xb_mpd:_cons]    \ _se[xb_mpd:_cons]   \ ///
                   .                   \ .                   \ ///
                   _b[xb_space:_cons]  \ _se[xb_space:_cons] \ ///
                   .                   \ .                   \ ///
                   _b[xb_price:_cons]  \ _se[xb_price:_cons] \ r(num_inelastic))
    
    * Column 3 (OLS w/ logs)
    foreach var of varlist price hpwt space mpg {
        replace `var' = log(`var')
    }
    replace trend = year    // transform trend to get the same intercept coefficient
    
    reg price hpwt air mpg space trend
    matrix TABLE = nullmat(TABLE) ,          ///
                   (_b[_cons] \ _se[_cons] \ ///
                   _b[hpwt]   \ _se[hpwt]  \ ///
                   _b[air]    \ _se[air]   \ ///
                   .          \ .          \ ///
                   _b[mpg]    \ _se[mpg]   \ ///
                   _b[space]  \ _se[space] \ ///
                   _b[trend]  \ _se[trend] \ . \ . \ .)
    matrix_to_txt, saving(../output/tables.txt) mat(TABLE) format(%20.3f) ///
        title(<tab:ols_logit>) append
    file open f using ../output/tables.txt, write append
    file write f "(`ols_inelastic_lower'-`ols_inelastic_upper')" _tab
    file write f "(`iv_inelastic_lower'-`iv_inelastic_upper')" _tab "." _n
    file close f
    matrix TABLE = ols_r2 , ., e(r2)
    matrix_to_txt, saving(../output/tables.txt) mat(TABLE) format(%20.3f) title() append
end

* Replicates standard errors from BLP (1995)
program compute_2sls_se, eclass
    syntax, indep_var(varlist) inst_var(varlist)
    preserve
    
    predict resid
    * local inst_var const hpwt air mpd space own_* all_*
    foreach instrument of varlist `inst_var' {
        gen mom_`instrument' = `instrument' * resid
    }
    quietly corr mom_*, covariance
    matrix VCOV_MOM = r(C)
    
    mkmat `indep_var', matrix(X)
    mkmat `inst_var', matrix(Z)
    matrix JACOBIAN = Z' * X / _N
    matrix VCOV_PARAM = ///
        inv(JACOBIAN' * JACOBIAN) * JACOBIAN' * VCOV_MOM * JACOBIAN * inv(JACOBIAN' * JACOBIAN) / _N
    ereturn repost V = VCOV_PARAM
    
    restore
end

program compute_inelastic_demand, rclass
    syntax, price_coef_name(string)
    * Rounds inputs to ensure match with BLP (1995) table
    scalar price_coef = round(_b[`price_coef_name'], 0.001)
    scalar price_coef_se = round(_se[`price_coef_name'], 0.001)
    
    gen price_elasticity = -price_coef * price * (1-share)
    quietly count if price_elasticity < 1
    return scalar num_inelastic = `r(N)'
    
    gen price_elasticity_ci_upper = -(price_coef + 2*price_coef_se) * price * (1-share)
    quietly count if price_elasticity_ci_upper < 1
    return scalar ci_upper = `r(N)'
    
    gen price_elasticity_ci_lower = -(price_coef - 2*price_coef_se) * price * (1-share)
    quietly count if price_elasticity_ci_lower < 1
    return scalar ci_lower = `r(N)'
    
    drop price_elasticity*
end

* EXECUTE
main
