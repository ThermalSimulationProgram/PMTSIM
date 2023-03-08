function [func, tables] = getLinearFuncHandles(data)

n = numel(data);
func = cell(1, n);
tables = cell(1, n);
numseg = 5;
for i = 1 : n
    toff = data{i}(2,:);
    T = data{i}(1,:);
    
    table = linearApproximate(toff, T, numseg, -1);
    f = @(x) functemplate(x, table);
    func{i} = f;
    tables{i} = table;
end




end