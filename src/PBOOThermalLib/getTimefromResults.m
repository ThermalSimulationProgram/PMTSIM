function [Timeall, config] = getTimefromResults(resultData)


config = resultData.config;

a = resultData.resultANPT.exetime;
b = resultData.resultBS.exetime;
c = resultData.resultDPA.exetime;
d = resultData.resultFBPT.exetime;

if numel(a) == numel(b) && numel(a) == numel(c) && numel(a) == numel(d)
    Timeall = [a; b; c; d];
else
    maxn = max([numel(a), numel(b), numel(c), numel(d)]);
    Timeall = zeros(4, maxn);
    Timeall(1, 1:numel(a)) = a;
    Timeall(2, 1:numel(b)) = b;
    Timeall(3, 1:numel(c)) = c;
    Timeall(4, 1:numel(d)) = d;
end

end

