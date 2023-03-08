function core = updateInfo(core)
now             = core.currentTime;
load            = getLoad(core);
setIdArray      = [];
setValueArray   = [];
loadId          = 3;
finishId        = 4;
%% check state if is proper
if core.state == 1 && load > core.deltaT
    error('can not be idle when still have workload');
end
if core.state == 2 && isempty(core.myevent)
    error('no load to handle');
end
%% determine next finish time
if isempty(core.myevent)
    newFinishTime = inf;
    noEventCore = core;
else
    if  abs( core.controlTrace(1,2) - now ) > core.deltaT
        error('control trace error');
    end
    
    [noEventCore, log] = temperalSimKernel(core);
    
    if log.stopId ~= 1
        warning('control trace is too short');
    else
        newFinishTime = log.stopTime;
    end
end
setIdArray = [setIdArray, finishId];
setValueArray = [setValueArray, newFinishTime];

noEventCore.myevent = [];


%% determine next load time
newLoadTime = core.nextEventLoadTime;
%  while no events is waiting in FIFO 
if core.inputFifo.Q <= 0
    newLoadTime = inf;
else % events are waiting in FIFO
    [~, log] = temperalSimKernel(noEventCore);
    if log.stopId ~= 2
        warning('control trace is too short');
    else
        newLoadTime = log.stopTime;
    end
end
setIdArray = [setIdArray, loadId];
setValueArray = [setValueArray, newLoadTime];


%% update all changes
core = setTime(core, setIdArray, setValueArray);
