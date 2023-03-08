function [stdrst] = normalizeTem(Temall)

minTem = Temall(1,:);
maxTem = max(Temall);

stdrst = zeros(size(Temall,1) - 1 , size(Temall,2));

for i = 1 : size(stdrst,1)
    stdrst(i,:) = ( Temall(i+1,:) - minTem ) ./ (maxTem - minTem);
end





end