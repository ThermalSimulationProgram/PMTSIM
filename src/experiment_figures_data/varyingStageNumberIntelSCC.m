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
c.tracelen = 15000;
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
c.deltaT = 0.4;

%results =cell(1, max(activeNums));

deadline_fun = @(x) 0.2 + 0.1*x;

load('PBOOvaryingStageNum-IntelSCC-newdeadline.mat');
% for m = 14:16
%     c = changeStageNumConfig(c, m,  deadline_fun(m));
%     resultData = offlineOptimizaPBOO(c);
%     results{m} = resultData;
%     if issave
%     save('PBOOvaryingStageNum-IntelSCC-newdeadline', 'results');
%     end
% end
c.allwcets = round(c.allwcets/c.deltaT)*c.deltaT;
%load('PBOOvaryingStageNum-IntelSCC-newdeadline.mat');
%oldoptbs = [0    0.9800    0.8800    0.9200    0.9900    0.9500    0.9300 ...
 %    0.9400 0.9300    0.9500    0.9500    0.9600]; %sampleT = 20


%oldoptbs = [0    0.9100    0.9000    0.9000    0.9100    0.9500    0.9600 ...
%    0.9100    0.9400  0.9000    0.9700    0.9700];%sampleT = 25

%oldoptbs = [ 0    0.8600    0.9500    0.8700    0.9100    0.9900    0.9600 ...
%    0.9800    0.9800 0.9200    0.9400    0.9900]; % sampleT = 20.

%oldoptbs = [0         0         0    0.9700    0.9600    0.9100    0.9600    0.9800    0.9200...
 %   0.9400    0.9100    0.9400    0.8900    0.9100    0.9500    0.9200];\
 
 
oldoptbs = [0         0         0    0.9900    0.9900    0.9800    0.9800    0.9900...
    0.9900    0.9900    0.9900    0.9900    0.9900    0.9800    0.9900    0.9900];%sampleT=5
c.sampleT = 5;
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
    


caseA_nums = [];
caseB_nums = [];

simnum = 1;

allresults = cell(simnum, 8);

tempT1 = zeros(simnum, 8);
tempT2 = zeros(simnum, 8);
tempT3 = zeros(simnum, 8);

%optbs(48) = 0.95;

for j = 1 : simnum
    
    
    for m = activeNums
       % c.sampleT = 16 - m * c.deltaT;
        c = changeStageNumConfig(c, m, deadline_fun(m));
        c.bcoef = optbs(m);     
        
        
        control = [1,0,0];
        if control(3)
            % pboo data
        c.hasPbooResult = true;
        c.resultData = results{m};
        end
        result = runApproaches(c, control);
        caseA_nums = [caseA_nums, result.aptm.pipeline.caseA_num];
        caseB_nums = [caseB_nums, result.aptm.pipeline.caseB_num];
        allresults{j,m} = result;
        if control(1)
            tempT1(j,m) = result.aptm.peakT;
            
        end
        if control(2)
            tempT2(j,m) = result.bws.peakT;
        end
        if control(3)
            tempT3(j,m) = result.pboo.peakT;
        end
        if issave
            save(filename, 'optbs','allresults');
        end
    end
end





