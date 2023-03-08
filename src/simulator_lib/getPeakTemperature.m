function [peakT, localpeaks] = getPeakTemperature(pipeline)

if isempty(pipeline.TemTrace)
    peakT = [];
    return;
end

localpeaks = zeros(1, pipeline.nstage);
for i = 1 : pipeline.nstage
    localpeaks(i) = max(pipeline.TemTrace(:,i));
end
peakT = max(localpeaks);     
     
end
