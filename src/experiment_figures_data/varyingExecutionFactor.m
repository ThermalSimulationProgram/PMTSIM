
%clear;
%devices_sel only is used for compatiable for original code;

load('offlineDataARM3cores.mat');
load('APTPTM_ARM3cores3.mat');
filename = 'NewARM3varyingExefactor';
issave = 0;
c = defaultSimConfig();
c.tracelen = 1000;
c.TM              = ARM3TM();
c.allwcets = [14.2;9;3.6];
c = changeStageNumConfig(c, 3, 1.2);
simulation = 1;
executionFactor = 0.1 : 0.1 : 1;
factor = executionFactor;
nfactors = numel(executionFactor);

optbs = [];
 oldoptbs = [0.9800    0.9800    0.9700    0.9700    0.9700    0.9700...
    0.9700    0.9700    0.9700    0.9700];
c.deltaT = 0.1;
c.allwcets = floor(c.allwcets/c.deltaT)*c.deltaT;
c.sampleT = 18;
for i = 1 : nfactors
    try
        optbs(i) = oldoptbs(i);
    catch
        
        c.exefactor = executionFactor(i) * ones(1, 3);
        c = newInputConfig(c);
        [optbcoef,peakTs,objs] = optimizeBcoef(c, [0.85, 0.99]);
        optbs(i) = optbcoef;
        if issave
            save(filename, 'optbs');
        end
    end
end




simnum = 20;

allresults = cell(simnum, nfactors);

tempT1 = zeros(simnum, nfactors);
tempT2 = zeros(simnum, nfactors);
tempT3 = zeros(simnum, nfactors);

for j = 1 : simnum
    
    
    for i = 1 : nfactors
        c.bcoef = optbs(i);     
        
        c.exefactor = executionFactor(i) * ones(1, 3);
        c = newInputConfig(c);
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











% TBET=1; %ms
% T=5;
% deadline_factor=1;
% trace(:,3)=trace(:,1)+deadline_factor*stream(1);
% [stage PowerADPM]= dpmSimTimePipeline_SingleStream_Tem(traceLen, stream, WCETs,...
% deadline_factor,devices_sel,accu_trace,trace,TBET,T);
% stage
%
%
% finish1 = zeros(size(eventArray));
% for i = 1 : numel(eventArray)
%     finish1(i) = obj.outPort.eventArray(i).finishTime;
% end
%
% finish2 = stage{3, 1}.finishTrace(:)';
%
% maxerror  =max(abs(finish1-finish2))
