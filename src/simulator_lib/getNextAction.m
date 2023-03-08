function [nextAction] = getNextAction(obj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: getNextAction.m
% getNextAction(obj) finds next action that will happen in obj.
% There are four types of action (ordered by priority):
%           arrive: An coming event arrives to the first core in obj.
%           finish: An event finishes its execution on current core.
%           load: An core loads an event stored in its input FIFO.
%           adapt: Run the dynamic adaption task managing how cores sleep.
% If any two or more actions happen at the same time, the one having higher
% priority is choosen.
% Input:    obj             The pipeline object
% Output:   nextAction      a structure containing:
%                           type: the type of next action
%                           time: the time of next action
%                           id: the index of core where the action happens
%
% Author: Long
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% finds actions on all cores 
% The number of all possible actions, each core at most has one, plus the
% adapt action
actN =  obj.nstage + 1;
% initial
nextTime = zeros(1, actN);
actId = zeros(1, actN);
actType = cell(1, actN);

% find action on each core, this action is choose also by priority
for i = 1 : actN - 1
    [time, actionType, id] = nextActionTime(obj.coreArray(i));
    nextTime(i) = time;
    actId(i) = id;
    actType{i} = actionType;
end
% get all action-times, smaller subsriput means higher priority
nextTime(actN) = obj.adaptTime;
actId(actN) = 0;
actType{1,actN} = 'adapt';
% scale all times to integer, for accurate comparison
nextTime = round(nextTime / obj.deltaT);

% ordered by priority
[minTime, indice] = min(nextTime);
nextAction.time = minTime * obj.deltaT;
nextAction.id = actId(indice);
nextAction.type = actType{1, indice};
end