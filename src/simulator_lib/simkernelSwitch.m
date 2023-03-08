function [obj, retlog] = simkernelSwitch(obj, startTime, endTime, switchTo)


if  obj.remainSwitch < 0
    error('not the state');
end
if switchTo == obj.sleep
    obj.state = obj.swoff;
    targetGroup = obj.sleep;
else if switchTo == obj.active || switchTo == obj.idle
        obj.state = obj.swon;
        targetGroup = obj.active;
    else
        error('wrong switchTo');
    end
end

retlog.id = 0;
retlog.time = endTime;

%%  switching
timelength = endTime - startTime;
if round(obj.remainSwitch/obj.deltaT) >= round( timelength/obj.deltaT)
    nowState = obj.state;
    newState = [nowState, startTime, endTime];
    obj.stateTrace = [obj.stateTrace; newState ];
   % obj.eventFinishTime = obj.eventFinishTime + timelength;
    obj = updateTemTrace(obj, startTime, endTime, 1);
    obj.remainSwitch = round( (obj.remainSwitch - timelength) /obj.deltaT ...
        ) * obj.deltaT;
    obj.state = nowState;
    if targetGroup == obj.active
        obj.sleepTime = 0;
    else
        obj.sleepTime = obj.sleepTime + timelength;
    end
else
    error('time length too large, including other states');
end
end