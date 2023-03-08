function [path, filepath] = getPath(options)

mfile       = options.mfile;
iopattern   = options.iopattern;
iofiletype  = options.iofiletype;
filename    = options.filename;

if isempty(mfile) || isempty(iopattern) || isempty(iofiletype) || isempty(filename)
    path        = -1;
    filepath    = -1;
    return;
end

[PATHSTR,~,~] = fileparts(mfile);

cd(PATHSTR);

stop = 0;

str2cmp = {'input';'result';'playground';'src'};

relativePath = [];
count = 0;
while ~stop
    cd ..;
    result = ls;
    
    
    n = size(result, 1);
    
    flag = zeros(1,4);
    m = numel(flag);
    for j = 1 : m
        for i = 1 : n
            if strcmp(deblank(result(i,:)), str2cmp{j})
                flag(j) = 1;
                break;
            end
            
        end
    end
    
    
    if prod(flag) > 0 || count >= 20
        stop = 1;
    end
    relativePath = strcat(relativePath, '../');
    count = count + 1;
end



switch iopattern
    case 'o'
        path = strcat(relativePath, 'result/' );
        switch iofiletype
            case 'f'
                path = strcat(path, 'figures/' );
            case 'd'
                path = strcat(path, 'data/' );
        end
        
    case 'i'
        path = strcat(relativePath, 'input/' );
end

filepath = strcat(path, filename);

% cd to the correct directory to ensure result path works
cd(PATHSTR);
end