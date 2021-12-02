function estimate
    addpath(genpath('../external/'));
    
    checksum_file = '../output/checksum.log';
    
    data = BlpData('blp_1999_data.csv', 'meanincome.csv', 'sdincome.csv', 'unobs_pub.csv');
    
    model = BlpModel();
    model = model.LoadStartParam('published_param.csv');
    model = model.SetupInstruments({}, data, 0.99);
    
    demand_iv_var = data.GetArray(model.demand_iv_varlist);
    supply_iv_var = data.GetArray(model.supply_iv_varlist);
    iv_var = blkdiag(demand_iv_var, supply_iv_var);
    wmatrix = inv(iv_var'*iv_var);
   
    % Constrains sigma parameters to be positive
    estopts = BlpEstimationOptions();
    estopts.lower_bound = [0 0 0 0 0 -Inf];
    
    tic;
    est = model.Estimate(data, wmatrix, estopts);
    estimation_time = toc;

    label = 'Parameter estimates for model with (sigma >= 0), BLP (1999) unobservables:';
    write_checksum(checksum_file, label, est);

    save('../output/blp_estimation.mat', 'est');
    
    % Saving estimation time and number of variables for text.pdf
    iv_dim = size(iv_var);
    number_iv = iv_dim(2);
    fid = fopen('../output/BLP_time_IV.txt', 'w'); 
    fprintf(fid, '%s\n', '<tab:BLP_time_IV>'); 
    fprintf(fid, '%2.5f\n', number_iv); 
    fprintf(fid, '%2.5f\n', estimation_time); 
    fclose(fid);
    
    exit
end

function write_checksum(checksum_file, label, est)
    diary(checksum_file);
    diary on
    disp(label);
    est.Play();
    diary off
end