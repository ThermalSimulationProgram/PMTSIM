function Tinit = H2Tinit(H, B, T0, id)

if nargin < 4
    id = 1 : size(H,2);
end

invBT0 = B \ T0;
for j = 1: size(H,3)
    H(:,id,j) =  H(:,id,j) * invBT0(j);
end
Tinit =  sum(H(:,id,:), 3)';
end
