function H = retrievenH(TM, t)
n = TM.n;
l = numel(t);
H = zeros(l,n,n,'single');

for i = 1 : n
    for j = 1 : n
        H(:,i,j) = TM.fitResults{i,j}.fitresult(t);
    end
end

end