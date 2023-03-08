function [toffs,tons,Tpeak,feasible] = getTheBestToffsDPA(partition,TM,n)

n = TM.n;
if size(partition,2)~= n
    error('partition error');
end

%% initialize 
toffs = zeros(1,n);
tons = inf * ones(1,n);
Tpeak = max(TM.T_inf_a);
feasible = 0;

%%
fesbl = zeros(n,2);
cand = cell(1,n);
limitoff = zeros(1,n);
        
for j=1:n
    index = TM.coreIdx(j);
    fesbl(j,1) = tswoffs(index) ;
    fesbl(j,2) = partition(j)  - tswons(index);
    cand{j} = fesbl(j,1) : step2 : fesbl(j,2);
    limitoff(j) = size(cand{j},2);
end

toff_idx = ones(1,n);
        
    
    
        
        