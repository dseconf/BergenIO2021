function data_cell = SplitDataByMarket(obj)
%
% Splits a BlpData object into smaller BlpData objects by market.
%
%
% OUTPUTS
%     - data_cell: A cell array of BlpData objects where each 
%                  element contains data from only one market
%

market_vec = obj.GetArray(obj.varlist.market);
market_levels = obj.market_levels;
data_cell = cell(obj.nmarkets, 1);
for i = 1:obj.nmarkets
    market = market_levels(i);
    market_indices = ismember(market_vec, market);
    data_cell{i} = obj.Select(market_indices, ':');
end

end