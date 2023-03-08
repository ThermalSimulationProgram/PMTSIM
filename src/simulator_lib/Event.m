
function obj = Event(id, nstage, wcetIn, currentTime, deadline, deltaT)
if any( [id, nstage, wcetIn, currentTime, deadline, deltaT] < 0 )
    error('all positive inputs required');
end

if numel(wcetIn) ~= nstage
    error('nstage not consistent with wcet input');
end
obj.id          = id;
obj.nstage      = nstage;
obj.wcetArray   = round( wcetIn/deltaT ) * deltaT;
obj.arrivalTime = round( currentTime/deltaT ) * deltaT;
obj.deadline    = round( deadline/deltaT ) * deltaT;
obj.remainedLoad= obj.wcetArray;
obj.deltaT      = deltaT;
obj.allremained = sum(obj.remainedLoad);
obj.finishTime  = inf;
obj.exeTrace    = [];

obj.absDeadline = obj.deadline;
obj.curStage    = 0;
obj.executed    = 0;
end



