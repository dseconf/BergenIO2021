function write_text_table(table, file, rownames, colnames, name, precision, mode, appendspace)

    % Set defaults
    if nargin<5
        name = [];
    end
    if nargin<6 || nargin>6 & isempty(precision)
        sf_fractions = 3;
        exp10 = max( ceil( log10( min( abs(table(:) ) ) ) ), 0 );
        ndigits = sf_fractions - exp10;
        precision = max(ndigits,0);
    end
    precision = ['%0.', num2str(precision), 'f'];
    if nargin<7 || nargin>7 & isempty(mode)
        mode = 'w';
    end
    if nargin<8 && isequal(mode,'a')
        appendspace = 19;
    end

    % Prepare table
    table = cellfun(@(x) num2str(x, precision), num2cell(table), 'UniformOutput', false);
    table = [rownames(:), table];
    table = [{' '}, colnames(:)'; table];
    if ~isempty(name)
        table = [repmat({''}, 2, size(table, 2)); table];
        table{1, 1} = name;
    end
    if isequal(mode, 'a')
        table = [table; repmat({''}, appendspace, size(table, 2))];
    end
    maxlengths = max( cellfun(@length, table) );

    % Define format
    rowformat = '';
    for i = 1:length(maxlengths)
        if i~=length(maxlengths)
            rowformat = [rowformat, '%-', num2str( maxlengths(i) ), 's\t'];
        else
            rowformat = [rowformat, '%-', num2str( maxlengths(i) ), 's\n'];
        end
    end

    % Write table
    fid = fopen(file, mode);
    for i = 1:size(table,1)
        fprintf(fid, rowformat, table{i,:});
    end
    fclose(fid);
end
