function alldata = offlineLearning(TM, step)
if nargin < 2
    step = [];
end
if isempty(step)
    step = 1;
end
slopes = 0.01 : 0.01*step : 0.97;
nslope = numel(slopes);
alldata =cell(1, nslope);
[TM] = completeTM(TM);
name = ['alldata-', TM.name];
j = 0;
try
    load(name);
    startid = j+1;
catch
    startid = 1;
end

startid = 1;

for j = startid : nslope
    tswons = ones(1, TM.n);
    tswoffs = tswons;
    slope = slopes(j);
    step =1;
    [toffs, T] = tempCurveAtSlopeFastVersion(TM, tswons, tswoffs, slope, step);
    
    
    data = cell(1, TM.n);
    
    for i = 1 : TM.n
        Ti = T{i};
        %relax = max(0.3, 0.05 * ( max(Ti) - min(Ti)));
        %relax = 0;
        toffvec = toffs{i};
%         minIndex = find(abs(Ti - min(Ti))<1e-4, 1,'first');
%         
%         toffForLearning = toffvec(1:minIndex);
%         TiForLearning = Ti(1:minIndex);
% 
%         data{i} = [TiForLearning; toffForLearning];
data{i} = [Ti; toffvec];
    end
    
    alldata{j} = data;
    
    
   % save(name,'alldata','j');
    
end
