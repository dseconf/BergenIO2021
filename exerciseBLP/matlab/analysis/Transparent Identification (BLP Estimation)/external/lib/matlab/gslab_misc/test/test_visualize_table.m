function test_visualize_table

rng(12345)
data_one = rand(8);
data_two = rand(8, 4);
data_three = rand(4, 8);
se_mat_three = rand(4, 8);
lower_ci = zeros(4,8);
upper_ci = zeros(4,8);
for i = 1:size(data_three,1)
    for j = 1:size(data_three,2)
        lower_ci(i,j) = data_three(i,j) - 1.96 * se_mat_three(i,j);
        upper_ci(i,j) = data_three(i,j) + 1.96 * se_mat_three(i,j);
    end
end

row.long  = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'};
row.short = {'a', 'b', 'c', 'd'};
col.long  = {'s', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
col.short = {'s', 't', 'u', 'v'};

% test default options on multiple matrix sizes
visualize_table(data_one, row.long, col.long);
visualize_table(data_two, row.long, col.short);
visualize_table(data_three, row.short, col.long);

% test using same options for multiple tables
red_green_opt = VisualizeTableOptions('rgb_low',  [.8, .2, .2], ...
                                      'rgb_high', [.2, .8, .2], ...
                                      'split', 0.7, ...
                                      'visible', true);

visualize_table(data_one, row.long, col.long, red_green_opt);
visualize_table(data_two, row.long, col.short, red_green_opt);

% test colormap_scale
colorscale_opt = VisualizeTableOptions('binary_color', false, ...
                                       'colormap_scale', 'summer', ...
                                       'visible', true);

visualize_table(data_one, row.long, col.long, colorscale_opt);

% test the rest of the non-Matlab options
other_data = rand(4);
other_row = {'abc def', 'ghi jkl', 'mno', 'pqr'};
other_col = {'ijk', 'lmn opq', 'rst uvw', 'xyz'};

other_opt = VisualizeTableOptions('precision', 2, 'gridlines', false, ...
                                  'cell_width', .75, 'cell_height', .3, ...
                                  'pad_width', 2.5, 'pad_height', .75, ...
                                  'visible', true);
other_opt = other_opt.multiline_label('col');
other_opt = other_opt.shift_label('row', -1, -.1);
other_opt = other_opt.shift_tabletext(.1, -.1);

visualize_table(other_data, other_row, other_col, other_opt);

% test Matlab options
matlab_opt = VisualizeTableOptions('visible', true);
matlab_opt.label_props.col.Color = [.3, .6, .2];
matlab_opt.tabletext_props.FontAngle = 'italic';
matlab_opt.axes_props.YMinorGrid = 'on';
matlab_opt.figure_props.Name = 'test table';

visualize_table(data_one, row.long, col.long, matlab_opt);

% test se_mat options and ci_cell options
se_opt = matlab_opt;
se_opt.se_mat = se_mat_three;
visualize_table(data_three, row.short, col.long, se_opt);

se_opt.se_mat = [];
se_opt.lower_ci = lower_ci;
se_opt.upper_ci = upper_ci;
visualize_table(data_three, row.short, col.long, se_opt);

% test when data cell is struct of lower/upper confidence intervals
ci_opt = matlab_opt;
ci_data = struct('lower', lower_ci, 'upper', upper_ci);
visualize_table(ci_data, row.short, col.long, ci_opt);
end