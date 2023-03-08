function [time, actionType, id] = nextActionTime(core)
id = core.id;
if core.nextEventLoadTime < core.eventFinishTime && ~isempty(core.myevent)
    ss = 1;
    error('can not load before event finished');
end
[time, indice] = min([core.inputFifo.nextEventInTime, core.nextEventLoadTime,core.eventFinishTime]);

if isinf(time)
    actionType = 'No action';
    return;
end

switch indice
    case 1
        actionType = 'arrive';
    case 2
        
        
        if ( abs(core.nextEventLoadTime - core.eventFinishTime) < core.deltaT &&...
                ~isempty(core.myevent))
            actionType = 'finish';
        else
            actionType = 'load';
        end
    case 3
        actionType = 'finish';
end
end
