function flp = generateFlp(node, table)

num = size(node, 1);
validateattributes(table, {'double'},{'size',[num,4]});
Nodes = flpNode(1, num);

dist = zeros(1, num);

for i = 1 : num
    fnSet(Nodes(i), table(i, 1), table(i, 2), table(i, 3), table(i, 4), i, node{i});
    dist(i) = fnGetDist( Nodes(i), Nodes(1));
end

for i = 1 : num
    for j = 1 : num
        fnTestNeighb(Nodes(i), Nodes(j));
    end
end

flp = struct('dist',dist,'Nodes',Nodes,'num',num);
