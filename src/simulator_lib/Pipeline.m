function obj = Pipeline(TM, nstage, tswonArray, tswoffArray, deltaT, ...
    displayInterval, activeCoreIdx)

% function obj = Pipeline(TM, nstage, tswonArray, tswoffArray, deltaT, adaptTime,...
%     sampleT, scheduleKernel, bcoef, offlineData, displayInterval, activeCoreIdx)
%
% TM: the thermal model
% nstage: number of stages of the pipeline (should be the number of cores)
% tswonArray: the switching on overheads of all stages
% tswoffArray: the switching off overheads of all stages
% deltaT: time resolution of TM, unit in millisecond
% displayInterval: interval of printing debug info
% activeCoreIdx: the stages which are used/turned on in the simulation

%% construct arrays of cores and FIFOs
coreArray = [];
fifoArray = [];
if nargin < 6
    displayInterval = [];
end
if nargin < 7
    activeCoreIdx = [];
end
if isempty(displayInterval)
    displayInterval = 1;
end
if isempty(activeCoreIdx)
    activeCoreIdx = 1 : nstage;
end


for i = 1 : nstage
    coreArray = [coreArray, Core(i, tswonArray(i), tswoffArray(i), 0, deltaT)];
    tempf = FIFO();
    fifoArray = [fifoArray, tempf];
end
obj.inPort = [];
obj.outPort = FIFO();
for i = 1 : nstage
    coreArray(i) = setInFifo(coreArray(i), fifoArray(i));
    if i == nstage
        coreArray(i) = setOutFifo(coreArray(i), obj.outPort);
    end

    coreArray(i).displaytick = 0;
    coreArray(i).displayInterval = displayInterval;
end
%% thermal model
if ~isempty(TM)
    obj.TM = TM;
    if obj.TM.n < nstage
        error('not correct nstage or thermal model');
    end
    if any(obj.TM.n < activeCoreIdx) || numel(activeCoreIdx) ~= nstage
        error('wrong indexes of active cores');
    end

    obj.activeCoreIdx = activeCoreIdx;
else
    obj.TM = [];
end
% thermal data
if ~isempty(obj.TM)
    if obj.TM.n > 1
        
        A_a         = obj.TM.A_a;
        INVC        = obj.TM.INVC;
        [U0, D0]    = eig(INVC * A_a);
        obj.TM.U0   = U0;
        obj.TM.D0   = D0;
    end
    obj.T       = obj.TM.initT;
    obj.nTtrace = 0;
    obj.block   = 5000;
    obj.sTtrace = 5000;
    obj.TemTrace    = zeros(obj.block, nstage);
    obj.TimeTrace   = zeros(obj.block, 1);
else
    obj.T       = 300 * ones(nstage, 1);  % initial temperature 300K
    obj.TemTrace    = [];
    obj.TimeTrace   = [];
end


%% static fields
obj.nstage      = nstage;
obj.fifoArray   = fifoArray;
obj.coreArray   = coreArray;
% no online adaption
obj.GE          = 0; % greedy execution.
obj.PTM         = 1; % periodic switch on/off
% with online adaption, requires package adaption_lib
obj.BWS         = 2; % balance workload scheme, optimize energy
obj.APTM       	= 3; % balance temperature scheme, optimize temperature
obj.RL          = 4; % Reinforce learning
obj.kernel      = []; % indicate kernel is not set yet!

obj.deltaT      = deltaT;
obj.tswons      = round(tswonArray/deltaT)*deltaT;
obj.tswoffs     = round(tswoffArray/deltaT)*deltaT;

obj.localPeakT = 0;
obj.saveconfig = false;
obj.configs = [];

obj.offlineData = [];
obj.bcoef = [];
obj.elapsetime  = [];
obj.adaptcounter = [];
obj.adaptTime = inf;
obj.adaptPeriod = inf;
obj.tons = [];
obj.toffs = [];
obj.caseA_num = 0;
obj.caseB_num = 0;
obj.currentTime = 0;

end




