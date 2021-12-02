function figure_handle = visualize_table (data, row_names, col_names, options)
%
% Creates a table of input matrix with option to color cells based on their values.
%
% Inputs:
%   data:               Matrix of data to be used as table cell values
%   row_names:          Cell array of strings to be used as row names
%   col_names:          Cell array of strings to be used as column names
%   options:            A VisualizeTableOptions object (Default value: a
%                       default VisualizeTableOptions object)
% Output:
%   figure_handle: The integer handle of the created figure
%
    
    if nargin < 4
        options = VisualizeTableOptions();
    end

    figure();
    
    if ~options.visible
        set(gcf, 'Visible', 'off');
    end   
    if ~isempty(options.lower_ci) && ~isempty(options.upper_ci)
        options.cell_width = options.cell_width * 1.6;
    end
    
    if all(isfield(data, {'lower', 'upper'}))
        options.cell_width = options.cell_width * 1.6;
        [counts.row, counts.col] = size(data.lower);
    else
        [counts.row, counts.col] = size(data);
    end
    
    resize_grid(counts, options);
    fill_table(data, counts, options)
    add_labels(row_names, col_names, counts, options)
    color_cells(options);
    add_gridlines(counts, options);
    add_props(options);

    figure_handle = gcf;
end

function resize_grid (counts, options)
    axes_width  = counts.col * options.cell_width;
    axes_height = counts.row * options.cell_height;
    paper_width  = axes_width  + 2 * options.pad_width;
    paper_height = axes_height + 2 * options.pad_height;

    set(gcf, 'PaperUnits', 'Inches', ...
             'PaperSize', [paper_width, paper_height], ...
             'PaperPosition', [0, 0, paper_width, paper_height], ...
             'Units', 'Inches', ...
             'Position', [0, 0, paper_width, paper_height]);
    set(gca, 'Units', 'Inches', ...
             'Position', [options.pad_width, options.pad_height, axes_width, axes_height]);
end

function fill_table (data, counts, options)
    if all(isfield(data, {'lower', 'upper'}))
        data_size = size(data.lower);
        imagesc(data.lower);
    else
        data_size = size(data);
        imagesc(data);
    end
    text_strings = cell(data_size);
    
    se_mat = options.se_mat;
    lower_ci = options.lower_ci;
    upper_ci = options.upper_ci;
    for i = 1:data_size(1)
        for j = 1:data_size(2)
            if isempty(se_mat) && isempty(upper_ci)
                if all(isfield(data, {'lower', 'upper'}))
                    prec_str = strcat('[',options.precision_str,',',options.precision_str,']');
                    text_ij = sprintf(prec_str, data.lower(i,j), data.upper(i,j));
                else
                    text_ij = sprintf(options.precision_str, data(i,j));
                end
            elseif ~isempty(se_mat)
                 prec_str = strcat(options.precision_str, ' \n', '(', options.precision_str, ')');
                 text_ij = sprintf(prec_str, data(i,j), se_mat(i,j));
            else 
                 prec_str = strcat(options.precision_str, ' \n', ... 
                                   '[', options.precision_str, ',', options.precision_str, ']');
                 text_ij = sprintf(prec_str, data(i,j), lower_ci(i,j), upper_ci(i,j));
            end
            text_strings(i,j) = cellstr(text_ij);
        end
    end
    
    [x, y] = meshgrid(1:counts.col, 1:counts.row);
    shift = options.tabletext_shift;
    tabletext = text(x(:) + shift.x, y(:) + shift.y, text_strings(:));

    for prop = fields(options.tabletext_props)'
        set(tabletext, prop{:}, options.tabletext_props.(prop{:}));
    end          
end

function add_labels(row_names, col_names, counts, options)
    set(gca, 'XTick', 1:counts.col, ....
             'XTickLabel', [], ...
             'XAxisLocation', 'top', ...
             'YTick', 1:counts.row, ...
             'YTickLabel', [], ...
             'TickLength', [0 0]);
    
    names.col = col_names;
    names.row = row_names;
    for axis = {'col', 'row'}
        if options.label_multiline.(axis{:}).multi
            names.(axis{:}) = insert_newlines(names.(axis{:}), options.label_multiline.(axis{:}).newline);
        end
    end

    labels.col = [];
    shift = options.label_shift.col;
    for xx = 1:counts.col
        labels.col = [labels.col, ...
                      text(xx + shift.x, shift.y, names.col{xx})];
    end    
    
    labels.row = [];
    shift = options.label_shift.row;
    for yy = 1:counts.row
        labels.row = [labels.row, ...
                      text(shift.x, yy + shift.y, names.row{yy})];
    end
    
    for axis = {'col', 'row'}
        for prop = fields(options.label_props.(axis{:}))'
            for i = 1:length(labels.(axis{:}))
                set(labels.(axis{:})(i), prop{:}, options.label_props.(axis{:}).(prop{:}));
            end
        end
    end
end

function new_names = insert_newlines (old_names, newline_char)
    for i = 1:length(old_names)
        new_names{i} = strrep(old_names{i}, newline_char, '\newline');
    end
end

function color_cells (options)
    if options.binary_color
        eta = 10^-6;
        set(gca, 'CLim', [options.split-eta options.split]);
    end
    colormap(options.colormap);
end

function add_gridlines (counts, options)
    if options.gridlines
        xv1 = repmat((2:counts.col) - 0.5, [2 1]); 
        xv1(end+1,:) = NaN;
        xv2 = repmat([0.5; counts.col + 0.5; NaN], [1 counts.row-1]);
        
        yv1 = repmat([0.5; counts.row + 0.5; NaN], [1 counts.col-1]);
        yv2 = repmat((2:counts.row) - 0.5, [2 1]);
        yv2(end+1,:) = NaN;
        
        line([xv1(:); xv2(:)], [yv1(:); yv2(:)], 'Color', [0, 0, 0])
    end
end

function add_props (options)
    for prop = fields(options.axes_props)'
        set(gca, prop{:}, options.axes_props.(prop{:}));
    end

    for prop = fields(options.figure_props)'
        set(gcf, prop{:}, options.figure_props.(prop{:}));
    end
end