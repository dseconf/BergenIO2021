%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% LOADPARAM.M: Load the value of a parameter from an input file. The input file is assumed to
%   have the structure:
%
%   --------- begin file ----------
%   param1 VALUE1
%   param2 VALUE2
%   --------- end file ------------
%
%   where param1, param2 are names of the parameters and VALUE1, VALUE2, etc are real numbers
%
% INPUTS:
%	p   string      name of parameter to load
%   f   string      name/path of file to load from
%	
% OUTPUTS:
%	v   scalar      value of parameter
%	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function v = loadparam(p,f)

if nargin~=2 
    error('Function loadparam must be called with exactly two inputs')
end
if ~ischar(p) || ~ischar(f) 
    error('Inputs p and f must be strings')
end

% try to open file
fid = fopen(f, 'r');
if fid==-1
	error(['Could not open file ' f])
end

found = 0;
while feof(fid) == 0
   line = fgetl(fid);
   regexpstr = ['^' p ' ([\-\.\d]+)$'];
   tok=regexp(line,regexpstr,'tokens','once');
   if ~isempty(tok)
       if found==0
           v = str2num(tok{:});
           found=1;
       else
           error(['Parameter ' p ' defined twice in file ' f]);
       end
   end
end
fclose(fid);

if found==0
    error(['Parameter ' p ' not found in file ' f]);
end
