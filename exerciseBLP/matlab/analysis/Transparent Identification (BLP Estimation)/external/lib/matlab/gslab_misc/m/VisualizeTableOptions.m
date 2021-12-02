classdef VisualizeTableOptions
%
% VisualizeTableOptions defines options for visualize_table
%

properties
    visible         = false;            % Display table in new Matlab window
    binary_color    = true;             % Two background colors for cells or color continuum
    rgb_low         = [1, 1, 1];        % If binary_color: rgb value for cells with value below split
    rgb_high        = [1, 1, 1];        % If binary_color: rgb value for cells with value above split
    split           = 0;                % If binary_color: value below which cells are colored rgb_low and
                                        %                        above which cells are colored rgb_high
    colormap_scale  = 'default';        % If not binary_color: Matlab colormap to use for coloring cells
    field_width     = 0;                % First arg in Matlab numeric formatting
    precision       = 4;                % Second arg in Matlab numeric formatting
    gridlines       = true;             % Display gridlines in table
    cell_width      = 1;                % Width (in inches) of each cell
    cell_height     = 1;                % Height (in inches) of each cell
    pad_width       = 1;                % Width (in inches) of whitespace to the left and right of the table
    pad_height      = 1;                % Height (in inches) of whitespace above and below the table
    se_mat          = [];               % Standard error matrix that will be displayed in parenthesis 
    lower_ci        = [];               % Matrix of lower bound of confidence interval
    upper_ci        = [];               % Matrix of upper bound of confidence interval
                                        
    label_multiline = struct('col', struct('multi', false, 'newline', ' '), ... % Break labels into multiple
                             'row', struct('multi', false, 'newline', ' '))     % lines using newline as break

    label_shift     = struct('col', struct('x', 0, 'y', 0), ... % Shift labels x inches to the right and y
                             'row', struct('x', 0, 'y', 0));    % inches down (negative values: left/up)
                             
    tabletext_shift = struct('x', 0, 'y', 0);                   % Shift tabletext x inches to the right and y
                                                                % inches down (negative values: left/up)
    
    % Valid values for the *_props properties can be found in the online Matlab documentation
    label_props     = struct('col', struct('FontWeight', 'bold'), ...   % Structs mapping text properties to 
                             'row', struct('FontWeight', 'bold'));      % property values for label text

    tabletext_props = struct('HorizontalAlignment', 'center');  % Struct mapping text properties to 
                                                                % property values for text in table                             

    axes_props      = struct();         % Struct mapping axes properties to desired property values
    figure_props    = struct();         % Struct mapping figure properties to desired property values
end

properties (Dependent)
    precision_str;
    colormap;
end

methods
    function obj = VisualizeTableOptions(varargin)
        if nargin > 0
            obj = obj.AssignOptions(varargin{:});
        end
    end

    function precision_str = get.precision_str (obj)
        precision_str = strcat('%', int2str(obj.field_width), '.', int2str(obj.precision), 'f');
    end

    function colormap = get.colormap (obj)
        if obj.binary_color
            colormap = [obj.rgb_low; obj.rgb_high];
        else
            colormap = obj.colormap_scale;
        end
    end
    
    function obj = shift_label (obj, axis, x_shift, y_shift)
        obj.label_shift.(axis).x = x_shift;
        obj.label_shift.(axis).y = y_shift;
    end
    
    function obj = shift_tabletext(obj, x_shift, y_shift)
        obj.tabletext_shift.x = x_shift;
        obj.tabletext_shift.y = y_shift;
    end
    
    function obj = multiline_label (obj, axis, newline)
        obj.label_multiline.(axis).multi = true;
        if nargin > 2
            obj.label_multiline.(axis).newline = newline;
        end
    end
end

methods (Hidden, Access = protected)
    function obj = AssignOptions(obj, varargin)
        option_struct = parse_option_list(varargin{:});
        for field = fieldnames(option_struct)'
            obj.(field{:}) = option_struct.(field{:});
        end
    end
end

end