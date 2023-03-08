%% setting
clear;
filename = 'varyingStageNum-IntelSCC-varyingDeltaT-16sampleT';
issave = 0;
activeNums = 4:16;
% load thermal model
load('IntelSCCTM0.0001p.mat');
load('IntelSCCfloorplan.mat');
load('offlineDataIntelSCC.mat');

c = defaultSimConfig();
c.tracelen = 25000;
c.dispinterval      = 5;
c.allwcets = [8.200000,6.200000,7,5.800000,7.400000,6.200000,7.800000,7.800000,...
    7.800000,7,5.400000,5.800000,8.600000,5.800000,8.200000,7,9,5.400000,...
    6.600000,5.400000,9,5,8.200000,8.200000,8.600000,5.400000,6.600000,6.200000,...
    8.200000,6.600000,8.600000,5.800000,6.200000,5.400000,5.400000,8.600000,...
    7.400000,7,5.400000,8.600000,7.400000,6.600000,7,6.600000,5.400000,5.800000,...
    5.400000,5.800000]*0.8;
c.TM = IntelSCCTM();
c.FTM = TM;
c.flp = flp;
c.allofflineData = offlineData;
c.exefactor = 1*ones(1,48);
c.deltaT = 1;

%results =cell(1, max(activeNums));

deadline_fun = @(x) 0.2 + 0.1*x;


c.allwcets = round(c.allwcets/c.deltaT)*c.deltaT;
oldoptbs = [0         0         0    0.9900    0.9900    0.9800    0.9800    0.9900...
    0.9900    0.9900    0.9900    0.9900    0.9900    0.9800    0.9900    0.9900];%sampleT=5
c.sampleT = 15;
if ~exist('oldoptbs')
    for m = activeNums
        c = changeStageNumConfig(c, m, deadline_fun(m));
        [optbcoef,peakTs,objs] = optimizeBcoef(c, [0.76, 0.99]);
        optbs(m) = optbcoef; 
        if issave
            save(filename, 'optbs');
        end
    end
else
    optbs = oldoptbs;
end
    





simnum = 1;

allresults = cell(simnum, 8);

%optbs(48) = 0.95;

for j = 1 : simnum
    
    
    for m = activeNums
       % c.sampleT = 16 - m * c.deltaT;
        c = changeStageNumConfig(c, m, deadline_fun(m));
        c.bcoef = optbs(m);     
        
        
        control = [1,1,0];
        if control(3)
            % pboo data
        c.hasPbooResult = true;
        c.resultData = results{m};
        end
        result = runApproaches(c, control);
        allresults{j,m} = result;
        if issave
            save(filename, 'optbs','allresults');
        end
    end
end


allconfigs = allresults{1, 11}.aptm.pipeline.configs;
nconfig=numel(allconfigs);
tt=tic;
for i = 1:nconfig
    [toffs, tons] = newBTS(allconfigs(i));
end
t1=toc(tt);


allconfigs2 = allresults{1, 11}.bws.pipeline.configs;
nconfig2=numel(allconfigs2);
tt=tic;
for i = 1:nconfig2
    [toffs] = BWS(allconfigs2(i));
end
t2=toc(tt);




