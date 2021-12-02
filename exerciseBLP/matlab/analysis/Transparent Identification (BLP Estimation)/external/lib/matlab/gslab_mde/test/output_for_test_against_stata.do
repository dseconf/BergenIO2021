 /**********************************************************
 *
 *  OUTPUT_FOR_TEST_AGAINST_STATA.DO
 * 
 **********************************************************/ 

version 12
set more off
adopath + ../external/gslab_misc
preliminaries

program main
    import_raw_data, obs(100)
    run_linear_gmm
    run_linear_gmm_with_instr
end

program import_raw_data
    syntax, obs(int)
    insheet using "../external/data/test_data.csv", clear
    drop if _n > `obs'
end

program run_linear_gmm 
    gmm (y_norm - {b0} - {xb: x1 x2}), instr(x1 x2) onestep 
    matrix parammat = e(b)
    matrix vcovmat = e(V)
    local outfile stataout_linear.txt
    matrix_to_txt, matrix(parammat) saving(parammat_`outfile') format(%19.0g) replace
    matrix_to_txt, matrix(vcovmat) saving(vcovmat_`outfile') format(%19.0g) replace
end


program run_linear_gmm_with_instr
    gmm (y_norm - {b0} - {b1}*x1), instr(x3 x4) onestep 
    matrix parammat = e(b)
    matrix vcovmat = e(V)
    matrix wmat = e(W)
    local outfile stataout_linear_instr.txt
    matrix_to_txt, matrix(parammat) saving(parammat_`outfile') format(%19.0g) replace
    matrix_to_txt, matrix(vcovmat) saving(vcovmat_`outfile') format(%19.0g) replace
    matrix_to_txt, matrix(wmat) saving(wmat_`outfile') format(%19.0g) replace
end

main

