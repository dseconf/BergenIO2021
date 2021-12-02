function test_write_text_table
%
% Unit tests for write_text_table function
%
rng('default')

outfile = 'test_text_table.txt';
table = rand(4,4);
rownames = {'one', 'two', 'three', 'four'};
colnames = rownames;

% Test precision
test_precision(table, rownames, colnames, 0,'%0.3f', outfile);
test_precision(table, rownames, colnames, 2,'%0.2f', outfile);
test_precision(table, rownames, colnames, 8,'%0.0f', outfile);

% Test title is added
test_title_added(table, rownames, colnames, 'Test Table Label', outfile);

% Test append mode
test_append_mode(table, rownames, colnames, outfile, 19);

delete(outfile);
end

function test_precision(table, rownames, colnames, order, format, outfile)
    table = table.*10^order;
    write_text_table(table, outfile, rownames, colnames);
    data = importdata(outfile);
    testtable = str2num( num2str(table(:), format) );
    assert( all(data.data(:)== testtable) );
end

function test_title_added(table, rownames, colnames, title, outfile)
    write_text_table(table, outfile, rownames, colnames, title);
    data = textread(outfile,'%s','delimiter','\n');
    assert( isequal( deblank(data{1}), title ) );
    assert( isequal( data{2}, '' ) );
end

function test_append_mode(table, rownames, colnames, outfile, appendspace)
    delete(outfile);
    write_text_table(table, outfile, rownames, colnames,[], [],'a', appendspace);
    write_text_table(table, outfile, rownames, colnames,[], [],'a', appendspace);
    data = textread(outfile,'%s','delimiter','\n');
    table_length = size(table,1)+size(rownames,1);
    assert( all( cellfun('isempty',data(table_length+1:table_length+appendspace) ) ) );
    assert( all( cellfun('isempty',data(2*table_length+1+appendspace:2*(table_length+appendspace)) ) ) );
    assert(  isequal( data(1:table_length), data(table_length+appendspace+1:2*table_length+appendspace )) );
end
