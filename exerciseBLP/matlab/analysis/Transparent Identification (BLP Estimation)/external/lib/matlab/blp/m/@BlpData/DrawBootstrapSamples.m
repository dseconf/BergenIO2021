function bootsample_cell = DrawBootstrapSamples(obj, numbootstrap, unobs_per_market)
%
% Draw bootstrap sample from the raw data blocked on year
% INPUTS
%     - numbootstrap      : number of bootstrap samples. 
%     - unobs_per_market  : number of unobservables drawn per market,
%                           default is 10 unobservables/market.
%
% OUTPUTS
%     - bootsample_cell   : A cell array of BlpData objects where each 
%                           element contains a bootstrapped sample. 
%        

rng(210304057);
if nargin < 3
    unobs_per_market = 10;
end

market_vec = obj.GetArray(obj.varlist.market);
unobs_year_vec = obj.unobs_year;
bootsample_cell = cell(numbootstrap, 1); 
for i = 1:numbootstrap 
    bootstrap_market = sort(datasample(obj.market_levels, obj.nmarkets));
    bootstrap_indices = [];
    unobs_indices = [];
    market_names = [];
    for j = 1:obj.nmarkets
        bootstrap_indices_j = find(market_vec == bootstrap_market(j));
        bootstrap_indices = [bootstrap_indices; bootstrap_indices_j];
        duplicate_market_stub = j - min(find(bootstrap_market == bootstrap_market(j))) + 1;
        market_name = str2double(sprintf('%d%d', bootstrap_market(j), duplicate_market_stub));
        market_names = [market_names; repmat(market_name, length(bootstrap_indices_j), 1)];
        
        unobs_indices_market = find(unobs_year_vec == bootstrap_market(j));
        unobs_indices_j = unobs_indices_market((duplicate_market_stub-1)*unobs_per_market + 1: ...
                                                duplicate_market_stub*unobs_per_market);
        unobs_indices = [unobs_indices; unobs_indices_j];
    end
    
    bootsample = obj.SelectUnobs(unobs_indices, obj.unobs_weight(unobs_indices));
    bootsample = bootsample.Select(bootstrap_indices, ':');
    bootsample.var.year = market_names;
    bootsample_cell{i} = bootsample;
end
end