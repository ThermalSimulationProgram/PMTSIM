function [core, log] = temperalSimKernel(core, endTime)
% call
%   core = temperalSimKernel(core):
%       simulate current core till next event happens
%   core = temperalSimKernel(core, endTime)
%       simulate current core from now to endTime
% 
% simulating terminate conditions:
%       0, simulate to endTime, or simulate to the end of control trace.
%       zero indicates no event happens.
%       1, finish execution of current event.
%       2, load an event from its input FIFO

if nargin < 2
    endTime = [];
end
startTime   = round(core.currentTime/core.deltaT) * core.deltaT;
ctrlTrace   = core.controlTrace;
if  round(ctrlTrace(1, 2)/core.deltaT) ~=  round(startTime/core.deltaT)
    error('incomplete trace');
end
if isempty(endTime)
    endTime = ctrlTrace(end, 3);
end
endTime     = round(endTime/ core.deltaT) * core.deltaT;
if ctrlTrace(end, 3) < endTime
    ctrlTrace = [ctrlTrace; core.active, ctrlTrace(end, 3), endTime];   
end

simulating = true;
segcounter = 1;

% scale time instances, to gain better compare accuracy
ctrlTrace(:, 2:3) = round(ctrlTrace(:, 2:3)/core.deltaT);
scaledEndTime   = round(endTime/core.deltaT);
nsegement       = size(ctrlTrace, 1);

log.stopId      = [];
log.stopTime    = [];
core.cTrace     = [];
while simulating
    cmdstate = ctrlTrace(segcounter, 1);
    endtime  = ctrlTrace(segcounter, 3);
    srttime  = ctrlTrace(segcounter, 2);
    
    realEnd = min(endtime, scaledEndTime);
    [core, retlog] = simcore(core, srttime*core.deltaT, realEnd*core.deltaT, cmdstate);
   
    if retlog.id > 0 ||... % indicates an event with id==1 or id==2 happens
            endtime >= scaledEndTime  % indicates simulate to endTime
        log.stopId = retlog.id;
        log.stopTime = retlog.time;
        remainTrace = ctrlTrace(segcounter:end,:);
        remainTrace(:, 2:3) = remainTrace(:, 2:3)*core.deltaT;
        remainTrace(1,2) = log.stopTime;
        core.controlTrace = remainTrace;
        break;
    end
    
    segcounter = segcounter + 1;
    if segcounter > nsegement % all controlTrace simulated, no reamin trace
        simulating = false;
        log.stopId = 0;
        log.stopTime = retlog.time;
    end
end

core.currentTime = log.stopTime;


end