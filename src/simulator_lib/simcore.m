function [obj, retlog] = simcore(obj, startTime, endTime, cmdstate)


if round(endTime/obj.deltaT) < round(startTime/obj.deltaT)
    error('negative time length');
end

if cmdstate ~= obj.active && cmdstate ~= obj.sleep
    error('error cmd state');
end
startTime   = round(startTime/obj.deltaT) * obj.deltaT;
endTime     = round(endTime/ obj.deltaT) * obj.deltaT;

if round(endTime/obj.deltaT) - round(startTime/obj.deltaT) < 1
    endTime = startTime;
end
totalTime = endTime - startTime;


%% first determine if the core is in switching process
previousState = obj.stateTrace(end, 1);

% default we consider scenario 1:  no switch
nextStateStartTime = startTime;
if totalTime > 0
    if obj.remainSwitch > 0 % must in switching, scenario 2: a old switch
        if previousState == obj.swoff || previousState == obj.idle || ...
                previousState == obj.active
            switchToState = obj.sleep;
        else if previousState == obj.swon || previousState == obj.sleep
                switchToState = obj.active;
            else
                error('not correct state');
            end
        end
        % calculate available time for switching
        switchTime = min(totalTime, obj.remainSwitch);
        % is switching to another state
        if switchToState ~= cmdstate
            % divide whole time into two parts: switching and then cmdstate
            nextStateStartTime = startTime + switchTime;
            [obj, ~] = simcore(obj, startTime, nextStateStartTime, switchToState);
            [obj, retlog] = simcore(obj, nextStateStartTime, endTime, cmdstate);
            return;
        else % is switching to cmdstate
            nextStateStartTime = startTime + switchTime;
            [obj, retlog] = simkernelSwitch(obj, startTime, nextStateStartTime, cmdstate);
        end
    else
        if previousState == obj.sleep || previousState == obj.swoff
            stateGroup = obj.sleep;
        else
            stateGroup = obj.active;
        end
        % scenario 3: a new switch
        % previous state conficts with cmdstate, needing a complete switch
        if stateGroup ~= cmdstate
            if cmdstate == obj.active
                obj.remainSwitch = obj.tswon;
            else
                obj.remainSwitch = obj.tswoff;
            end
            switchTime = min(totalTime, obj.remainSwitch);
            nextStateStartTime = startTime + switchTime;
            obj.state = obj.swon;
            [obj, retlog] = simkernelSwitch(obj, startTime, nextStateStartTime, cmdstate);
        end
    end
else
    retlog.id = 0;
    retlog.time = endTime;
end

%% then simulate remained part

startTime = nextStateStartTime;
if round(endTime/obj.deltaT) < round(startTime/obj.deltaT)
    error('negative time length');
end
startTime   = round(startTime/obj.deltaT) * obj.deltaT;
endTime     = round(endTime/ obj.deltaT) * obj.deltaT;
if round(endTime/obj.deltaT) - round(startTime/obj.deltaT) < 1
    endTime = startTime;
end

previousState = obj.stateTrace(end, 1);
simTime = endTime - startTime;
if simTime > 0
    switch cmdstate
        case obj.sleep
            obj.state = obj.sleep;
            [obj, retlog] = simkernelSleep(obj, startTime, endTime);
        case obj.active
            if isempty(obj.myevent) % keep in idle mode
                obj.state = obj.idle;
                [obj, retlog] = simkernelIdle(obj, startTime, endTime);
            else                    % handling event
                obj.state = obj.active;
                [obj, retlog] = simkernelActive(obj, startTime, endTime);
            end
    end
else
% handle critical conditions
    if cmdstate == obj.active && isempty(obj.myevent) && obj.inputFifo.Q > 0 &&...
            obj.remainSwitch == 0 && previousState ~= obj.sleep && ...
            previousState ~= obj.swoff
            retlog.id = 2;
            retlog.time = startTime; 
    else
        if cmdstate == obj.active && ~isempty(obj.myevent) && getLoad(obj) < obj.deltaT
            retlog.id = 1;
            retlog.time = startTime;
        else
            retlog.id = 0;
            retlog.time = endTime;
        end
    end
end
obj.currentTime = retlog.time;
end










