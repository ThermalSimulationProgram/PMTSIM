function resultData = mergeResultData(resultData1, resultData2)

% resultData2.resultFBPT = results();
% resultData2.resultANPT = results();
% resultData2.resultDPA  = results();
% resultData2.resultBS   = results();
% resultData2.config     = config;
if nargin < 2
    error('too few input arguments');
end
x = fields( resultData1 );
y = fields( resultData2 );

x = sort(x);
y = sort(y);
if ~isequal(x, y)
    warning('input two structure do not have the same fields')
end

n = max(numel(x), numel(y));

for i = 1 : n
    if ~isequal(x{i}, y{i})
        continue
    end
    
    if strcmp(x{i},'config')
            resultData.(x{i}) = [resultData1.(x{i}), resultData2.(x{i})];
    else
        
    resultData.(x{i}) = resultData1.(x{i}).copy;
    resultData.(x{i}).resultsMerge(resultData2.(x{i}));
    end

end