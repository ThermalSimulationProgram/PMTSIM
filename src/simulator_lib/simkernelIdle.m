function [obj, retlog] = simkernelIdle(obj, startTime, endTime)
retlog.id = 0;
if obj.remainSwitch > 0
    error('state switch process is not finished');
end
if obj.state ~= obj.idle
    error('not the state');
end

if isempty(obj.myevent) % keep in idle mode
    if obj.inputFifo.Q > 0
        retlog.id = 2;
        endTime = startTime;
    end
    newState = [obj.idle, startTime, endTime];
    obj.stateTrace = [obj.stateTrace; newState];
    obj = updateTemTrace(obj, startTime, endTime, obj.idlePower);
else
    error('can not be idle if still have workload');
end

retlog.time = endTime;
obj.sleepTime = 0;
end