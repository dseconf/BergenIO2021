function [nname, outstruct] = parse_name_list(namelist)
%
% Parse a standard cell array that contains a list of names into 
% a structure with the positional indices of the names
%
%
% INPUTS
%
%    - namelist:           a cell array containing the names to be parsed
%
% OUTPUTS
%
%    - nname:              the number of elements in namelist
%
%    - outstruct:          a structure with each element's name comes from namelist
%                          and each element contains the position of that name
    
    nname = length(namelist);
    outstruct = cell2struct(num2cell(1:nname)', namelist);
end

