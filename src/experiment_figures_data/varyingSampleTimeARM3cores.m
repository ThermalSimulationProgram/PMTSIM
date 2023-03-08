
%clear;
%devices_sel only is used for compatiable for original code;

load('offlineDataARM3cores.mat');
% setting
stream          = [100 150 0];
WCETs           = [14.2;9;3.6];
m               = 3;
tracetype       = 1;
traceLen        = 10000;
p               = [1;1;1];
deadlinefactor  = 1;
TM              = ARM3TM();
BWSKernel       = 1;
BTSKernel       = 2;
deltaT          = 0.1;
tswon           = 1;
tswoff          = 1;



%kernel = 0;
bcoef = 0.75;
%sampleT = 30;

inputTrace = generateInput(m, stream, deadlinefactor, WCETs, tracetype, traceLen, p);

havedata1 = 1;
if ~havedata1
    toffs = [5.39908848027660,11.4618914421234,12.1000000000000];
    tons = [15.2000   10.0000    4.6000];
    obj = Pipeline(TM, m, tswon*ones(1,m), tswoff*ones(1,m), deltaT, inf, sampleT,...
        kernel, bcoef, offlineData);
    
    obj = getInputs(obj, inputTrace);
    for i =1 : m
        core = obj.coreArray(i);
        setlength = traceLen * 3;
        core = getPTMcTrace(core, setlength,...
            tons(i), toffs(i));
        obj.coreArray(i) = core;
        
    end
    [obj] = simulate(obj);
    offPBOOT =  getPeakTemperature(obj);
else
    offPBOOT = 3.647647087349531e+02;
end

bwsT = [];
btsT = [];
optbcoefs = [];
for sampleT = 20 : 2 : 30
    kernel = BWSKernel;
    obj = Pipeline(TM, m, tswon*ones(1,m), tswoff*ones(1,m), deltaT, deltaT*3, ...
        sampleT, kernel, bcoef, offlineData);
    
    obj = getInputs(obj, inputTrace);
    
    [obj] = simulate(obj);
    bwsT = [bwsT, getPeakTemperature(obj)];
    
    kernel = BTSKernel;
    
    obj = Pipeline(TM, m, tswon*ones(1,m), tswoff*ones(1,m), deltaT, deltaT*3, ...
        sampleT, kernel, bcoef, offlineData);
    [optbcoef,peakTs] = optimizeBcoef(obj, inputTrace);
    optbcoefs = [optbcoefs, optbcoef];
    btsT = [btsT, min(peakTs)];
    
    save('varyingsampletime2', 'offPBOOT', 'bwsT', 'btsT', 'sampleT','optbcoefs' );
end

