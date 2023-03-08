function pipeline = pipelineAdaption(pipeline)
setlength = max(1000, pipeline.adaptPeriod * 4);
switch pipeline.kernel
    case pipeline.BWS
        
        config = getAdaptInfoBWS(pipeline, pipeline.accuTrace, pipeline.trace);
        if pipeline.saveconfig
            pipeline.configs = [pipeline.configs, config];
        end
        tt=tic;
        sleepInterval = BWS(config);
        time = toc(tt);
        pipeline.adaptcounter = pipeline.adaptcounter + 1;
        pipeline.elapsetime(pipeline.adaptcounter) = time;
        
        sleepInterval = floor( sleepInterval/pipeline.deltaT ) * pipeline.deltaT;
        sleepInterval = max(0, sleepInterval - 1);
        pipeline = setRateLatency(pipeline, sleepInterval, setlength);
        
    case pipeline.APTM

        config = getAdaptInfo(pipeline, pipeline.accuTrace, pipeline.trace);
        xx = config;
        % xx.offlineData = [];
        if pipeline.saveconfig
            pipeline.configs = [pipeline.configs, xx];
        end
        tt=tic;
        [toffs, tons, caseA_num, caseB_num] = newBTS(config);
        pipeline.caseA_num = pipeline.caseA_num + caseA_num;
        pipeline.caseB_num = pipeline.caseB_num + caseB_num;
        time=toc(tt);
        pipeline.adaptcounter = pipeline.adaptcounter + 1;
        pipeline.elapsetime(pipeline.adaptcounter) = time;
        
        for i = 1 : pipeline.nstage
            core = pipeline.coreArray(i);
            core = getPTMcTrace(core, setlength, tons(i), toffs(i));
            pipeline.coreArray(i) = core;
            
        end
    case pipeline.GE
        pipeline = setRateLatency(pipeline, zeros(1, pipeline.nstage), setlength);
    otherwise
        error('wrong kernel');
end

pipeline.adaptTime = round( (pipeline.adaptTime + pipeline.adaptPeriod)/pipeline.deltaT)*pipeline.deltaT;

end


function pipeline = setRateLatency(pipeline, sleepinterval, totallength)

for i = 1 : pipeline.nstage
    core = pipeline.coreArray(i);
    time1 = pipeline.currentTime + sleepinterval(i);
    time2 = pipeline.currentTime + totallength;
    controlTrace = [core.sleep, pipeline.currentTime, time1;...
        core.active, time1, time2];
    core.controlTrace = controlTrace;
    pipeline.coreArray(i) = core;
end
        
end
