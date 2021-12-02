classdef Tree
%
% Tree is a class of tree structures stored using the Ahnentafel list representation.
%
% Members of Tree are "complete" trees in the sense that every node other than the
% terminal nodes has the same number of children.
%
% Nodes in the tree are numbered from top-to-bottom then left-to-right. So in a binary tree,
% the root node is (1), the two children of the root node are (2) and (3), the two children of
% node (2) are (4) and (5), and so on. Information about the nodes is stored in a series of 
% properties where for property 'prop' the information for node i is in prop{i}.

    properties
        depth = 0           % Number of levels in binary tree
        numchi = 2          % Number of children of each non-terminal node
        numnodes = 1        % Number of nodes in binary tree
        terminal = 1        % Vector with indices of terminal nodes
        par = {[]}          % Index of i's parent node
        chi = {[]}          % Row vector with indices of i's child nodes (if any)
        level = {0}         % The level of the tree at which node i appears
        path = {[]}         % Row vec indicating the path to node i (in binary tree, left=1, right=2)
        childnum = {[]}     % Child number of this node (1, 2, 3, etc.)
        num_by_type = {[]}  % Number of times each branch taken in path to node i
    end

    properties (Dependent)
        numterminal
    end

    properties (Hidden)
        first_at_level      % Cell array used by FirstNodeAtLevel method
        nodes_at_level      % Cell array used by NodesAtLevel method
    end

    methods 
        function obj = Tree(depth, numchi)
            if nargin > 0
                obj.numchi = numchi;
                if depth > 0
                    for i = 1:depth
                        obj = obj.AddLevel;
                        obj.first_at_level{i} = Tree.ComputeFirstNodeAtLevel(i, obj.numchi);
                        obj.nodes_at_level{i} = Tree.ComputeNodesAtLevel(i, obj.numchi);

                    end
                end
            end
        end

        function num = get.numterminal(obj)
            num = length(obj.terminal);
        end

        function nodes = NodesAtLevel(obj, level)
        % Returns all indices of nodes at the given level
            if level == 0
                nodes = 1;
            else
                nodes = obj.nodes_at_level{level};
            end
        end

        function node = FirstNodeAtLevel(obj, level)
        % Returns the index of the first node at the given level
            if level == 0
                node = 1;
            else
                node = obj.first_at_level{level};
            end
        end
    end

    methods (Static)
        function nodes = FindNodes(input, numchi)
        % Takes as input a path vector or cell array of path vectors and returns the corresponding
        % vector of node indices. E.g., FindNodes([1 2 1]) = 10 & FindNodes([2]) = 3. This function
        % ignores any NaN values in the input vectors, so [1 2 1 Nan Nan] is treated like [1 2 1].
            if ~iscell(input)
                input = {input};
            end
            nodes = zeros(length(input), 1);
            for i = 1:length(input)
                vec = input{i} - 1;
                vec = vec(~isnan(vec));
                nodes(i) = Tree.ComputeFirstNodeAtLevel(length(vec), numchi) + ...
                    vec * (numchi.^(length(vec)-1 : -1 : 0)');
            end
        end

        function lev = FindLevel(node, numchi)
        % Returns the level of a given node in a tree with numchi children per node
            lev = floor(log(node)/log(numchi) + 1);
        end
    end

    methods (Hidden, Access = protected)
        function newobj = AddLevel(obj)
            newobj = obj;
            newobj.depth = obj.depth + 1;
            newobj.numnodes = obj.numnodes + obj.numchi*obj.numterminal;
            newobj.terminal = (obj.numnodes + 1) : (obj.numnodes + obj.numchi*obj.numterminal);
            for i = obj.terminal
                newobj.chi{i} = obj.FirstChild(i) + (0 : obj.numchi-1);
                for j = 1 : obj.numchi
                    newobj = newobj.AddChildNode(i,j);
                end
            end
        end

        function obj = AddChildNode(obj, par, childnum)
            node = obj.FirstChild(par) + childnum - 1;
            obj.par{node} = par;
            obj.chi{node} = [];
            obj.level{node} = obj.level{par} + 1;
            obj.path{node} = [obj.path{par} childnum];
            obj.childnum{node} = childnum;
            obj.num_by_type{node} = hist(obj.path{node}, 1:obj.numchi);
        end

        function node = FirstChild(obj, par)
            node = obj.numchi*(par - 1) + 2;
        end
    end

    methods (Static, Hidden)
        function nodes = ComputeNodesAtLevel(level, numchi)
            first = Tree.ComputeFirstNodeAtLevel(level, numchi);
            last = Tree.ComputeFirstNodeAtLevel(level+1, numchi) - 1;
            nodes =  first:last;
        end

        function node = ComputeFirstNodeAtLevel(level, numchi)
            node = sum(numchi.^(0 : (level-1))) + 1;
        end
    end

end
