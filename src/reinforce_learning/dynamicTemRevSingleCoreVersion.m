function [obj, simTrace] = dynamicTemRevSingleCoreVersion(obj, startTime, endTime, tons, toffs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DYNAMICTEM simulates the obj thermal model
% Inputs:       obj         -- the pipeline object
%               currentTime -- the simulation start time
% Output:       obj         -- the pipeline object with inputs
% Call: obj = dynamicTem(obj, inputTrace);
%       [obj, simTrace] = dynamicTem(obj, currentTime);
%
% version: 1.0, 27/12/2016
% author: Long, chengl@in.tum.de
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% shortcuts
TM = obj.TM;
n_units = TM.n;			% number of cores
n_nodes = TM.N;			% number of nodes
if n_units == 1
    n_nodes = 1;
else
    A_a = TM.A_a;
    A_i = TM.A_i;
    B_a = TM.B_a;
    B_i = TM.B_i;
    U0  = TM.U0;
    D0  = TM.D0;
end

tswons = obj.tswons;
tswoffs = obj.tswoffs;
% get the simulation initial temperatures
if isempty(obj.T)
    Tbegin = TM.initT;
else
    Tbegin = obj.T;
end

% prepare power segements for simulation
powerSegments = cell(1, n_units);

sleep = 0;
active = 1;
% put the obj cTrace in powerSegments
for i = 1 : obj.nstage
    id = obj.activeCoreIdx(i);
    ptmsegs = ptmPowerSegs(startTime, endTime, tons(id), toffs(id),...
        tswons(id), tswoffs(id), sleep, active);
    ptmsegs2 = zeros(size(ptmsegs));
    ptmsegs2(:, 1) = ptmsegs(:, 2);
    ptmsegs2(:, 2) = ptmsegs(:, 3);
    ptmsegs2(:, 3) = ptmsegs(:, 1);
    powerSegments{id} = ptmsegs2;
end

% transform power segement to C_trace according to time resolution deltaT
% C_trace is the cell array of traces of the accumulated computing time
[C_trace, tracelen] = powerSeg2Trace(powerSegments, n_nodes, n_units, obj.deltaT);

% simulation based on the thermal differential equation
if n_units > 1
    simTrace = MultiDE_fast(A_a, B_a, B_i, U0, D0, Tbegin(:), C_trace);
else
    tau = 1;
    [ X,  Y ] = new_DE(TM.g_a, TM.g_i, TM.T_inf_a, TM.T_inf_i, Tbegin(1), tau, C_trace{1}, 0);
    simTrace{1} = [X;Y];
end

% post processing simlation results
time = simTrace{1,1}(1,:) * 1000 + obj.currentTime;

startId = obj.nTtrace + 1;
endId = obj.nTtrace +  tracelen;
vIds = startId: 1 : endId;

if endId > obj.sTtrace
    obj.sTtrace = obj.sTtrace + max(obj.block, endId - obj.sTtrace);
    obj.TemTrace(obj.sTtrace, obj.nstage) = 0;
    obj.TimeTrace(obj.sTtrace, 1) = 0;
end
%% get the temperature at time instance t
T 	= zeros(1, n_nodes);
for i = 1 : n_nodes
    T(i) = simTrace{1,i}(2, tracelen);
end
obj.T = T;
if max(T) > obj.localPeakT
    obj.localPeakT = max(T);
end
Trace = zeros(tracelen, obj.nstage);
for i = 1 : obj.nstage
    id = obj.activeCoreIdx(i);
    Trace(:, i) =  simTrace{1,id}(2, :)';
end
obj.TimeTrace(vIds) = time(:);
obj.TemTrace(vIds, :) =  Trace;
obj.nTtrace = obj.nTtrace + tracelen;


end
