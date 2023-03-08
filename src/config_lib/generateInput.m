function inputTrace = generateInput(nstages, stream, deadlinefactor, WCETs, tracetype, traceLen, p)


%Generate Trace
WCETs = WCETs(:);
p = p(:);
[accu_trace, trace]=gentrace_BWS(stream, tracetype, traceLen, deadlinefactor,...
    WCETs, p, nstages);
[buckets, stepWidth, upperBoundsI] = initBucket(stream(1), stream(2), stream(3));

inputTrace.accuTrace    = accu_trace;
inputTrace.trace        = trace;
inputTrace.buckets      = buckets;
inputTrace.stepWidth   	= stepWidth;
inputTrace.upperBoundsI = upperBoundsI;
inputTrace.wcets        = WCETs;



