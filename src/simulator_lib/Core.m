function obj = Core(id, tswon, tswoff, startTime, deltaT)

%% static parameters
obj.id      = id;
obj.tswon   = round(tswon/deltaT)*deltaT;
obj.tswoff  = round(tswoff/deltaT)*deltaT;
obj.deltaT  = deltaT;
% state indicator
obj.sleep   = 0;
obj.idle    = 1;
obj.active  = 2;
obj.swon    = 3;
obj.swoff   = 4;
obj.resolution = deltaT;
obj.idlePower = 1;



%% dynamic data
% initial state
obj.inputFifo   = [];
obj.outputFifo  = [];
obj.state       = obj.idle;
obj.stateTrace  = [obj.idle, 0, 0];
obj.eventTrace  = []; % first column: event ids; second column: event wcets

obj.myevent             = [];
obj.currentTime         = startTime;
obj.nextEventLoadTime   = inf;
obj.eventFinishTime     = inf;
obj.sleepTime           = 0;
obj.cTrace              = [];
obj.remainSwitch        = 0;
obj.controlTrace        = [obj.active, 0, inf]; % default: turn on
end


























