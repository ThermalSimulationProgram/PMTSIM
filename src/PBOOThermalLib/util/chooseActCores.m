function activeCoreIdx = chooseActCores(flp, activeNum)

dist = flp.dist;
max  = flp.num;
if activeNum > max
    warning('too manying actived cores, all the cores are actived in this case');
    activeNum = max;
end
activeCoreIdx = zeros(1, activeNum);
for i = 1 : activeNum
    idx = find(dist == min(dist), 1, 'first');
    activeCoreIdx(i) = idx;
    dist(idx) = inf;
end
% sort the index, such that we can easily locate the cores
activeCoreIdx = sort(activeCoreIdx);