function funcs = getFuncHandles(alldata)

numslope = numel(alldata);
funcs = cell(size(alldata));

numseg = 4;

for i = 1 : numslope
    i
    localdata = alldata{i};
    tempdata = cell(size(localdata));
    for j = 1 : numel(localdata)
        toffs = localdata{j}(2,:);
        tem = localdata{j}(1,:);
        
        minIndex = find(abs(tem - min(tem))<1e-4, 1,'first');
        
        toffForLearning1 = toffs(1:minIndex);
        TiForLearning1 = tem(1:minIndex);
        
        table1 = linearApproximate(toffForLearning1, TiForLearning1, numseg, -1);
        
        
        toffForLearning2 = toffs(minIndex+1 : end);
        TiForLearning2 = tem(minIndex+1 : end);
        
        table2 = linearApproximate(toffForLearning2, TiForLearning2, numseg, 1);
        
        alltable = [table1; table2];
        f = @(x) functemplate(x, alltable);
        tempdata{j} = f;
        
        plot(toffs, tem, 'b', toffs, f(toffs), 'r');
        pause(0.05);
        clf;
        
    end
    
    funcs{i} = tempdata;
    
end






    




end