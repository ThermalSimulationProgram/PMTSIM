function [obj, retlog]= simkernelSleep(obj, startTime, endTime)
if obj.remainSwitch > 0
    error('state switch process is not finished');
end
if obj.state ~= obj.sleep
    error('not the state');
end

retlog.id = 0;
retlog.time = endTime;
newState = [obj.sleep, startTime, endTime];  	% sleep phase

obj.stateTrace = [obj.stateTrace; newState ];
obj.currentTime = endTime;
%obj.eventFinishTime = obj.eventFinishTime + timelength;
obj = updateTemTrace(obj, startTime, endTime, 0);
obj.sleepTime = obj.sleepTime + endTime - startTime;
end
