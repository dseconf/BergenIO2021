function [matrix, rowgroups, columngroups] = columnplot(matrix, rowgroups, rowgrouporder, columngroups, columngrouporder, colorlist, varargin)
%
% Creates a plot of input matrix.
%
% X axis corresponds to column dimension of matrix.  Y axis corresponds to
% row dimension of matrix.  Point is plotted at (x, y) if matrix(x, y) > 0.
% A subset of the rows and/or columns can be displayed and sorted into groups.
% Points can be plotted in different color groups if non-zero matrix entries are
% natural numbers corresponding to the colorlist index.
%
% Inputs:
%   matrix:             Matrix of data to be plotted.
%   rowgroups:          Vector giving a group id number for corresponding rows of
%                       matrix.
%   rowgrouporder:      Vector giving the order of row groups to be displayed.
%   columngroups:       Vector giving a group id number for corresponding columns of
%                       matrix.   
%   columngrouporder:   Vector giving the order of column groups to be displayed.
%   colorlist:          1xn Cell array of 1x3 vectors with entries indicating colors for each
%                       of the n color groups (vectors are Matlab Color Specifications, with three
%                       entries between 0 and 1 indicating R,G,B). If this argument is specified, 
%                       then entries in matrix should be positive integers corresponding to 
%                       the required color.
%   varargin:           Add argument 'columndrop' if you want to drop columns with all
%                       entries <= 0 or NaN for selected rowgroups. Add argument 'rowdrop' if you
%                       want to drop columns with all entries <= 0 or NaN for selected rowgroups.
%

    clf
    if all(all(matrix <= 0))
        varargin = {};
    end
    if nargin < 2
        rowgroups = [];
        columngroups = [];
    elseif nargin < 4
        columngroups = [];
    end
    if nargin < 6 || isempty(colorlist)
        colorlist{1} = 0.5*[1 1 1];
    end
	rowgridmark = [];
    columngridmark = [];
    
 	% drop empty columns or rows if required
    if sum(~cellfun('isempty',regexp(varargin, 'columndrop')))    
        [columngroups, matrix] = drop_empty(columngroups, matrix);
    end
    if sum(~cellfun('isempty',regexp(varargin, 'rowdrop')))
        [rowgroups, matrix] = drop_empty(rowgroups', matrix');
        [rowgroups, matrix] = deal(rowgroups', matrix');
    end

    % sort matrix and define groups
    if nargin > 2 && ~isempty(rowgrouporder)
		[matrix, rowgridmark, rowgroups] = sort_by_group(matrix, rowgroups, rowgrouporder);
	end
    if nargin > 4 && ~isempty(columngrouporder)
		[matrix, columngridmark, columngroups] = sort_by_group(matrix', columngroups, columngrouporder);
        matrix = matrix';
    end
      
	% print coordinates and grid
	[r c] = find(matrix>0);
	pos = prepare_grid;
	set(gcf,'Position',pos);
	Size = 10;
    hold on;
    if length(colorlist) == 1
        Color = colorlist{1};
        scatter(c, r,Size,Color,'o','filled');
    else
        for i = 1:length(colorlist)
            Color = colorlist{i};
            [r_color, c_color] = find(matrix == i);
            colorpoints = intersect([r,c], [r_color, c_color], 'rows');
            scatter(colorpoints(:,2), colorpoints(:,1),Size,Color,'o','filled');
        end
    end
	grid(rowgridmark, columngridmark);
    hold off;  
end

function [groups, matrix] = drop_empty(groups, matrix)
% Drops matrix columns with all entries NaN or 0

    if ~isempty(groups)
        groups = groups(:,~all(matrix <= 0 | isnan(matrix)));
    end
    matrix = matrix(:,~all(matrix <= 0 | isnan(matrix)));
    
end

function [sortmat, gridmark, plotted_groups] = sort_by_group(matrix, groups, grouporder)
% Sorts the data into ordered groups and drops groups not in grouporder
	
	numgroups = length(grouporder);
	obscount = 0;
    gridcount = 1;

	for i = 1:numgroups
		indices = find(groups == grouporder(i));
		for j = 1:length(indices)
			sortmat(obscount+j,:) = matrix(indices(j),:);
		end
		obscount = obscount + length(indices);
        if length(indices) > 0
            gridmark(gridcount) = obscount;
            plotted_groups(gridcount) = grouporder(i);
            gridcount = gridcount + 1;
        end
	end
	
end

function pos = prepare_grid
% Defines boundaries of graph

	screensize = get(0,'ScreenSize') ;
	r_left = screensize(1) ; 
	r_bottom = screensize(2) ; 
	r_width = screensize(3) ; 
	r_height = screensize(4) ; 

	left = r_left+r_width/8 ;
	bottom = r_bottom+r_height/8 ;
	width = r_width*.75 ; 
	height = r_height*.75 ; 
	pos = [left, bottom, width, height];

end

function grid(horiz_gridmark, vert_gridmark)
% adds grid lines

	% get limit of x axis
	hca=get(get(0,'currentfigure'),'currentaxes');
	xlimit = get(hca,'xlim') ;
    ylimit = get(hca,'ylim') ;

	% set up line data
	horiz_x_coordinates = repmat([xlimit(:) ; nan],1,numel(horiz_gridmark)) ;
	horiz_y_coordinates = repmat(horiz_gridmark(:).',3,1) ;
    vert_x_coordinates = repmat(vert_gridmark(:).',3,1) ;
	vert_y_coordinates = repmat([ylimit(:) ; nan],1,numel(vert_gridmark)) ;

	% add lines to axes
	h = line('xdata',horiz_x_coordinates(:),'ydata',horiz_y_coordinates(:)) ;
    set(hca,'ylim',ylimit,'xlim',xlimit) ;
    v = line('xdata',vert_x_coordinates(:),'ydata',vert_y_coordinates(:)) ;
    
	% push lines to the bottom of the graph
	uistack(h,'bottom') ; 
	uistack(v,'bottom') ;
    
    % format ticks and axes
    if ~isempty(horiz_gridmark)
        set(gca, 'YTick', horiz_gridmark)
        ylim([0, max(horiz_gridmark) + max(horiz_gridmark)/20])
    end
    if ~isempty(vert_gridmark)
        set(gca, 'XTick', vert_gridmark)
        xlim([0, max(vert_gridmark) + max(vert_gridmark)/20])
    end
end
