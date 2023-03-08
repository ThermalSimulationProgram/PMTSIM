
%clear;
%devices_sel only is used for compatiable for original code;
devices_sel=zeros(8,1); % to indicate there are 8 stages
load('offlineDataARM8cores.mat');
load('APTPTM_ARM8cores8.mat');
savename = 'varyingSamplePeriods8coresFinal';
issave = 0;
c = defaultSimConfig();


simulation = 1;
sample_periods = 16 : 2 : 36;

c.sampleT = 12;
nsamples = numel(sample_periods);
c.deltaT = 0.4;
c.allwcets = floor(c.allwcets/c.deltaT)*c.deltaT;

oldoptbs = [0.9900    0.9800    0.9900    0.9700...
    0.9600    0.9800    0.9500    0.9800];
optbs = [];
for i = 1 : nsamples
    try
        optbs(i) = oldoptbs(i);
    catch
        
        c.sampleT = sample_periods(i);
        [optbcoef,peakTs,objs] = optimizeBcoef(c, [0.85, 0.99]);
        optbs(i) = optbcoef;
        if issave
            save(filename, 'optbs');
        end
    end
end




simnum = 1;

allresults = cell(simnum, nsamples);

tempT1 = zeros(simnum, nsamples);
tempT2 = zeros(simnum, nsamples);
tempT3 = zeros(simnum, nsamples);

for j = 1 : simnum
    
    
    for i = 1 : nsamples
        c.bcoef = optbs(i);     
        
        c.sampleT = sample_periods(i);
        control = [1,1,1];
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






