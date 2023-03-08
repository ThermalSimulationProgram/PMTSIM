function state = getPipelineState(obj)
TemTrace = [];
if  obj.currentTime < obj.deltaT
    TemTrace = obj.TM.initT(1:obj.nstage, :);
    
else

    prevTemLength = round(obj.adaptPeriod/obj.deltaT);

    currentTempId = round(obj.currentTime/obj.deltaT);

    if currentTempId > prevTemLength
        TemTrace = obj.TemTrace(currentTempId-prevTemLength:currentTempId, :);

    else
        TemTrace = obj.TemTrace(1:currentTempId, :);
    end


end


traceLength = size(TemTrace, 1);

if traceLength > 1
    recentTraceLength = round(50/obj.deltaT);
    if recentTraceLength < traceLength
        recentTempMean = mean(TemTrace(traceLength-recentTraceLength:end,:  ) );
    else
        recentTempMean = mean(TemTrace );
    end

    halfLength = round(traceLength * 0.5);
    TemMean0 = mean(TemTrace(1:halfLength,:  ) );
    TemMean1 = mean(TemTrace(halfLength+1:end,:  ) );
    diffTemp = (TemMean1 - TemMean0)*2;

else
    maxTemps = TemTrace;
    diffTemp = 0;
    recentTempMean = TemTrace;
end


recentTempMean = recentTempMean(:);
diffTemp = diffTemp(:);


state = [recentTempMean; diffTemp];







end