function outstruct = parse_option_list(varargin)
%
% Parse standard options input into a struct with fields corresponding to
% options.
%
% The input to parse_option_list may be either a single struct, in which
% case that struct is simply returned as output, or a list of option-value
% pairs.
%
    assert( is_valid_input(varargin{:}),...
        'Input to parse_option_list must be a single struct or a list of option-value pairs');

    if nargin == 1
        outstruct = varargin{1};
    else
        outstruct = struct(varargin{:});
    end
end

function bool = is_valid_input(varargin)
    if nargin == 1
        bool = isstruct(varargin{1});
    else
        bool = mod(nargin,2)==0;
        
        % Odd-numbered inputs must be strings
        for i = 1:2:nargin-1
            bool = bool && ischar(varargin{i});
        end
    end
end

