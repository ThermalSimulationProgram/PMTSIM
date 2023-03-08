function tend = tendFromH(H, epsilon, p)
sizet = size(H,1);
tend= zeros( size(H,2),size(H,2));
for i = 1:size(H,2)
    for j = 1:size(H,3)
        peak =  find(H(:,i,j)==max(H(:,i,j)), 1, 'last' );
        pointEnd = sizet;
        while (pointEnd-peak>=5)
            midP = round((pointEnd + peak)/2);
            if H(midP,i,j) <= epsilon
                pointEnd = midP;
            else
                peak = midP;
            end
        end
        tend(i,j)=(pointEnd - 1) * p; %unit: sec
    end
end
end