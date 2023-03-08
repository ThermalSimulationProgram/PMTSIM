function result = runApproaches(config, control)


inputTrace      = config.inputTrace;
tswon           = config.tswon;
tswoff          = config.tswoff;
deltaT          = config.deltaT;
sampleT         = config.sampleT;
offlineData     = config.offlineData;
displayInterval = config.dispinterval;
m               = config.nstage;
TM              = config.TM;
activeCoreIdx   = config.activeCoreIdx;

config2         = config;
config2.FTM     = [];
result.config   = config2;
result.aptm = [];
result.bws = [];
result.pboo = [];

obj = Pipeline(TM, m, tswon*ones(1,m), tswoff*ones(1,m), deltaT,...
    displayInterval, activeCoreIdx);
obj = getInputs(obj, inputTrace);
if control(1) % approach aptm
    disp('BTSKernel');

    kdata.kernel = 'APTM';
    kdata.adaptPeriod = sampleT;
    kdata.bcoef = config.bcoef;
    kdata.offlineData = offlineData;
    
    obj1 = setKernel(obj, kdata);
    obj1 = simulate(obj1);
    peakT1 = getPeakTemperature(obj1);
    r1 = ret_template(obj1, peakT1);
    result.aptm = r1;
end


if control(2) % approach BWS
    disp('BWSKernel');
    
    kdata.kernel = 'BWS';
    kdata.adaptPeriod = sampleT;
    
    obj2 = setKernel(obj, kdata);
    obj2 = simulate(obj2);
    peakT2 = getPeakTemperature(obj2);
    r2 = ret_template(obj2, peakT2);
    result.bws = r2;
end

if control(3)
    if ~config.hasPbooResult
        resultData = offlineOptimizaPBOO(config);
    else
        resultData = config.resultData;
    end
    solutionOffline = resultData.resultFBPT.solution;
    disp('offline pboo simulation');
    toffs = solutionOffline(1, config.activeCoreIdx) ;
    tons = solutionOffline(2, config.activeCoreIdx) ;
    
    kdata.kernel = 'PTM';
    kdata.tons = tons;
    kdata.toffs = toffs;
    
    obj3 = setKernel(obj, kdata);
    [obj3] = simulate(obj3);
    peakT3 = getPeakTemperature(obj3);
    r3 = ret_template(obj3, peakT3);
    result.pboo = r3;
end
result = simplifyResult(result);
end


function r = ret_template(pipeline, T)
p = pipeline;
p.configs = [];
p.inPort = [];
r.pipeline = p;
r.peakT = T;
end

