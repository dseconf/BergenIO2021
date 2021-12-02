function test_tree
%
% Unit tests for Tree class
%

% Binary Trees
tree_empty = Tree();
tree0 = Tree(0, 2);
tree5 = Tree(5, 2);

assert( isequal(tree_empty, tree0) );

assert( isequal(tree5.depth, 5) );
assert( isequal(tree5.numnodes, 63) );
assert( isequal(tree5.terminal, 32:63) );
assert( isequal(tree5.numterminal, 32) );
assert( isequal(tree5.par{5}, 2) );
assert( isequal(tree5.chi{5}, [10 11]) );
assert( isequal(tree5.level{5}, 2) );
assert( isequal(tree5.path{5}, [1 2]) );
assert( isequal(tree5.num_by_type{5}, [1 1]) );

assert( isequal(Tree.FindNodes([1 2 2 1 2 NaN NaN], 2), 45) );
assert( isequal(tree5.path{45}, [1 2 2 1 2]) );
assert( isequal(tree5.childnum{45}, 2) );
assert( isequal(tree5.NodesAtLevel(5), 32:63) );
assert( isequal( Tree.FindLevel(9, 2), 4));

% Three-child Trees
tree0 = Tree(0, 3);
tree2 = Tree(2, 3);

assert( isequal(tree2.depth, 2) );
assert( isequal(tree2.numnodes, 13) );
assert( isequal(tree2.terminal, 5:13) );
assert( isequal(tree2.numterminal, 9) );
assert( isequal(tree2.par{4}, 1) );
assert( isequal(tree2.chi{4}, [11 12 13]) );
assert( isequal(tree2.level{4}, 1) );
assert( isequal(tree2.path{4}, [3]) );
assert( isequal(tree2.num_by_type{4}, [0 0 1]) );

assert( isequal(Tree.FindNodes([3 2], 3), 12) );
assert( isequal(tree2.path{12}, [3 2]) );
assert( isequal(tree2.childnum{12}, 2) );
assert( isequal(tree2.NodesAtLevel(1), 2:4) );
assert( isequal(tree2.NodesAtLevel(2), 5:13) );
assert( isequal( Tree.FindLevel(9, 3), 3));
