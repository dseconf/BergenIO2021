%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STR2CELL.M: Create a cell array from a string, breaking at a specified delimiter.
%
% INPUTS:
%	str     String to parse
%   del     Delimiter
%	
% OUTPUTS:
%	C       Output cell array
%
% Created: MG 9/08
% Modified:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function C = str2cell(str,del)

if ischar(str)==0
    error('First input to str2cell must be a character array')
end
if nargin==2 && ischar(del)==0
    error('Second input to str2cell must be a character array')
end

if nargin==1
    del=' ';
end

C = {};
while true
    [frag,str] = strtok(str,del);
    C = horzcat(C,frag);
    if isempty(str), break; end
end





