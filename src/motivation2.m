clear
load('motivation2OfflineData.mat');
load('APTPTM_ARM3cores3.mat');
filename = 'NewARM3varyingExefactor';
issave = 0;
c = defaultSimConfig();
c.stream   = [100, 0, 0];
c.deadlinefactor    = 1;
c.tracelen = 1000;
c.dispinterval      = 4;
c.TM              = ARM3TM();
c.allwcets = [10;10;10];
% load('ARM3coresTM.mat');
% coolingdata = offlineLearningMiniTact(TM, c.allwcets, 300, 1);
% [~, mtdata] = getLinearFuncHandles(coolingdata);
% offlineData.mtdata = mtdata;
c = changeStageNumConfig(c, 3, 1);
simulation = 1;
executionFactor =  1;
factor = executionFactor;
nfactors = numel(executionFactor);

optbs = [];
 oldoptbs = 0.92;
c.deltaT = 0.1;
c.allwcets = floor(c.allwcets/c.deltaT)*c.deltaT;
c.sampleT = 50;
for i = 1 : nfactors
    try
        optbs(i) = oldoptbs(i);
    catch
        
        c.exefactor = executionFactor(i) * ones(1, 3);
        c = newInputConfig(c);
        [optbcoef,peakTs,objs] = optimizeBcoef(c, [0.8, 0.99]);
        optbs(i) = optbcoef;
        if issave
            save(filename, 'optbs');
        end
    end
end




simnum = 1;

allresults = cell(simnum, nfactors);

tempT1 = zeros(simnum, nfactors);
tempT2 = zeros(simnum, nfactors);
tempT3 = zeros(simnum, nfactors);

for j = 1 : simnum
    
    
    for i = 1 : nfactors
        c.bcoef = optbs(i);     
        
        c.exefactor = executionFactor(i) * ones(1, 3);
        c = newInputConfig(c);
        control = [1,1,0];
        if control(3)
            % pboo data
        c.hasPbooResult = true;
        c.resultData = resultData;
        end
        result = runApproaches(c, control);
        allresults{j,i} = result;
        if control(1)
            tempT1(j,i) = result.aptm.peakT;
        end
        if control(2)
            tempT2(j,i) = result.bws.peakT;
        end
        if control(3)
            tempT3(j,i) = result.pboo.peakT;
        end
        if issave
            save(filename, 'optbs','allresults');
        end
    end
end


    
    
