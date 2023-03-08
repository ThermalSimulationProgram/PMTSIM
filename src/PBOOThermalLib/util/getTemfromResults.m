function [Temall, config] = getTemfromResults(resultData)


config = resultData.config;

a = resultData.resultANPT.miniTpeak;
b = resultData.resultBS.miniTpeak;
c = resultData.resultDPA.miniTpeak;
d = resultData.resultFBPT.miniTpeak;

if numel(a) == numel(b) && numel(a) == numel(c) && numel(a) == numel(d)
    Temall = [a; b; c; d];
else
    maxn = max([numel(a), numel(b), numel(c), numel(d)]);
    Temall = zeros(4, maxn);
    Temall(1, 1:numel(a)) = a;
    Temall(2, 1:numel(b)) = b;
    Temall(3, 1:numel(c)) = c;
    Temall(4, 1:numel(d)) = d;
end

end