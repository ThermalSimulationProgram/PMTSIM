function data = offlineLearningMiniTact(TM, tacts, maxtslp, step)


[TM] = completeTM(TM);
%name = ['secondalldata-', TM.name];

if nargin < 3
    maxtslp = [];
end
if nargin < 4
    step = [];
end
if isempty(maxtslp)
    maxtslp = 200;
end
if isempty(step)
    step = 1;
end
mintslp = 1;

data = cell(1, TM.n);


for j = 1 : TM.n
    j
    TMtslps = zeros(1, TM.n);
    TMtacts = TMtslps;
    TMtacts(j) = tacts(j);
    table = [];
    alltslp = mintslp:step:maxtslp;
    table(2,:) = alltslp;
    i = 1;
    for tslp = alltslp
        TMtslps(j) = tslp;
        [peakT, ~, TM] = CalculatePeakTemperatureV2(0, TM, TMtslps, TMtacts, []);
        table(1, i) = peakT;
        i = i + 1;
    end
    
    data{j} = table;
    
  %  save(name,'data');
    
end
