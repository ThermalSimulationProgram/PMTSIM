function [obj, retlog] = simkernelActive(obj, startTime, endTime)
retlog.id = 0;
if obj.remainSwitch > 0
    error('state switch process is not finished');
end
if obj.state ~= obj.active
    error('not the state');
end

activeTime = endTime - startTime;
load = getLoad(obj);
% the event out action is not handled if this case
if activeTime - load >= 0
    retlog.id = 1;
    endTime = startTime + load;
    activeTime = load;
end
% execute the event
[obj.myevent, ~, ~] = executed(obj.myevent, ...
    startTime, activeTime);
if round(getLoad(obj)/obj.deltaT) == 0
    retlog.id = 1;
    endTime = startTime + activeTime;
end

%obj.eventFinishTime = obj.eventFinishTime - activeTime;
newState = [obj.active, startTime,  endTime];
obj.stateTrace = [obj.stateTrace; newState];
obj = updateTemTrace(obj, startTime, endTime, 1);
obj.currentTime = endTime;
retlog.time = endTime;
obj.sleepTime = 0;
end