version 14
set more off
adopath + ../../external/stata/gslab_misc/ado
preliminaries

program main
    create_data
    estimate_model
    write_results
end

program create_data
    set obs 15

    gen y = runiform()
    gen x1 = runiform()
    gen x2 = runiform()
end

program estimate_model
    gmm (y - {b0} - {b1}*x1), inst(x1 x2) onestep vce(unadj)
    
    mat jacobian = e(G)
    mat weight = e(W)
    mat vcov_mom = syminv(weight)

    mat stata_vcov_param = invsym(jacobian'*weight*jacobian)
end

program write_results
    foreach m in jacobian vcov_mom weight stata_vcov_param {
        clear
        svmat `m'
        export delimited using "./`m'.csv", novarnames replace
    } 
end

* Execute
main
