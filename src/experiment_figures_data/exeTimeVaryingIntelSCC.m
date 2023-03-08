%% setting
clear;
filename = 'ExetimevaryingStageNum-IntelSCC';
issave = 0;
activeNums = 2 : 12;
% load thermal model
%load('IntelSCCTM0.0001p.mat');
load('IntelSCCfloorplan.mat');
load('offlineDataIntelSCC.mat');

c = defaultSimConfig();
c.dispinterval      = 50;
c.allwcets = [8.200000,6.200000,7,5.800000,7.400000,6.200000,7.800000,7.800000,...
    7.800000,7,5.400000,5.800000,8.600000,5.800000,8.200000,7,9,5.400000,...
    6.600000,5.400000,9,5,8.200000,8.200000,8.600000,5.400000,6.600000,6.200000,...
    8.200000,6.600000,8.600000,5.800000,6.200000,5.400000,5.400000,8.600000,...
    7.400000,7,5.400000,8.600000,7.400000,6.600000,7,6.600000,5.400000,5.800000,...
    5.400000,5.800000] ;
c.TM = IntelSCCTM();
c.flp = flp;
c.allofflineData = offlineData;
c.exefactor = 0.5*ones(1,48);

c.tracelen          = 50000;
c.deltaT        = 1;
results =cell(1, max(activeNums));

deadline_fun = @(x) 0.2 + 0.15*x;

% for m = activeNums
%     c = changeStageNumConfig(c, m,  deadline_fun(m));
%     resultData = offlineOptimizaPBOO(c);
%     results{m} = resultData;
%     save('PBOOvaryingStageNum-IntelSCC', 'results');
% end

%load('PBOOvaryingStageNum-IntelSCC.mat');
oldoptbs = [0    0.9800    0.8800    0.9200    0.9900    0.9500    0.9300 ...
     0.9400 0.9300    0.9500    0.9500    0.9600]; %sampleT = 20


c.sampleT = 20;
if ~exist('oldoptbs')
    for m = activeNums
        c = changeStageNumConfig(c, m, deadline_fun(m));
        [optbcoef,peakTs,objs] = optimizeBcoef(c, [0.8, 0.99]);
        optbs(m) = optbcoef;  
        save(filename, 'optbs');
    end
else
    optbs = oldoptbs;
end
    





simnum = 1;

allresults = cell(simnum, 8);

tempT1 = zeros(simnum, 8);
tempT2 = zeros(simnum, 8);
tempT3 = zeros(simnum, 8);


for j = 1 : simnum
    
    
    for m = activeNums
        c = changeStageNumConfig(c, m, deadline_fun(m));
        c.bcoef = optbs(m);     
        % pboo data
       % c.hasPbooResult = true;
       % c.resultData = results{m};
        
        result = runApproaches(c, [1,1,0]);
        result.config = getUsefulConfig(result.config);
        allresults{j,m} = result;
        if issave
            save(filename, 'optbs','allresults');
        end
    end
end





