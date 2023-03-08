function [obj, stage, nextstage] = executed(obj, currentTime, tlength)
if tlength < 0
    error('positive time required');
end

if isfinished(obj)
    stage = 0;
    nextstage = 0;
    return;
end
tlength = round( tlength / obj.deltaT ) * obj.deltaT;

% find the current stage
stage = find( obj.remainedLoad > 0, 1);

% the job will finish 
if stage == obj.nstage && obj.allremained <= tlength
    obj.finishTime = currentTime + obj.allremained;
    if round(obj.finishTime, 8) < round(obj.arrivalTime + sum(obj.wcetArray), 8)
        error('I can not finish before all execution time elapsed');
    end
end
% decrease the load 
before_exe = obj.remainedLoad(stage);
obj.remainedLoad(stage) = max(0, obj.remainedLoad(stage) - tlength);

obj.remainedLoad(stage) = round( obj.remainedLoad(stage) /...
    obj.deltaT ) * obj.deltaT;
after_exe = obj.remainedLoad(stage);
obj.executed = min(obj.wcetArray(stage), obj.executed + before_exe - after_exe);
obj.allremained = sum(obj.remainedLoad);
nextstage = find( obj.remainedLoad > 0, 1);
obj.exeTrace = [obj.exeTrace ; currentTime, currentTime + tlength, stage];

end