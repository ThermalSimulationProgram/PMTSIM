function [ttrace] = getTemperatureTrace(pipeline, coreId)

if isempty(pipeline.TemTrace)
    ttrace = [];
    return;
end

ttrace = pipeline.TemTrace(:, coreId);
     
end
