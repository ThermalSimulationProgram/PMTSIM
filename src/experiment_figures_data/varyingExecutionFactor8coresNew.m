
clear;
%devices_sel only is used for compatiable for original code;
devices_sel=zeros(8,1); % to indicate there are 8 stages
load('offlineDataARM8cores.mat');
load('APTPTM_ARM8cores8.mat');
filename = 'varyingExecutionFactor8coresFinal';
issave = 0;
c = defaultSimConfig();

%c.allwcets = [4.4000    3.6000    2.3000    0.8000    3.3000    3.9000    3.7000    4.8000];
c.allwcets = c.allwcets * 3;
c.deadlinefactor = 1.5;
simulation = 1;
executionFactor = 0.1 : 0.1 : 1;
factor = executionFactor;
c.sampleT = 15;
nfactors = numel(executionFactor);
c.deltaT = 0.1;
c.allwcets = floor(c.allwcets/c.deltaT)*c.deltaT;

optbs = [];
% oldoptbs = [0.9200    0.9300    0.9800    0.9800    0.9700...
%     0.9700    0.9900    0.9700    0.9700    0.9700]; 
oldoptbs = [0.9800    0.9900    0.9900    0.9900    0.9900    0.9800    0.9900    0.9700...
    0.9800    0.9700]; %sampleT = 18
% oldoptbs = [0.9800    0.9400    0.9900    0.9900    0.9800    0.9800    0.9900    0.9900    0.9900...
%     0.9800];
for i = 1 : nfactors
    try
        optbs(i) = oldoptbs(i);
    catch
        
        c.exefactor = executionFactor(i) * ones(1, 8);
        c = newInputConfig(c);
        [optbcoef,peakTs,objs] = optimizeBcoef(c, [0.85, 0.99]);
        optbs(i) = optbcoef;
        if issave
            save(filename, 'optbs');
        end
    end
end




simnum = 5;

allresults = cell(simnum, nfactors);

tempT1 = zeros(simnum, nfactors);
tempT2 = zeros(simnum, nfactors);
tempT3 = zeros(simnum, nfactors);

for j = 1 : simnum
    
    
    for i = 1 : nfactors
        c.bcoef = optbs(i);     
        
        c.exefactor = executionFactor(i) * ones(1, 8);
        c = newInputConfig(c);
        control = [0,1,0];
        if control(3)
            % pboo data
        c.hasPbooResult = true;
        c.resultData = resultData;
        end
        result = runApproaches(c, control);
        result = simplifyResult(result);
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
            save(filename, 'optbs','allresults','factor');
        end
    end
end

%save('xxxx20p1resolution','tempT1', 'tempT2', 'tempT3', 'allresults');






