function [toffs, tons] = getPTMs(candids, index)

acn = numel(index);

toffs = zeros(1, acn);
tons  = zeros(1, acn);

for i = 1 : acn
    toffs(i) = candids.candidToffs{i}(index(i));
    tons(i)  = candids.candidTons{i}(index(i));
end
end
