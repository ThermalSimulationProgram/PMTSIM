function config = ObtainConfig(alpha, deadline, wcets, tswons, tswoffs, step, activeNum, flp, N, n, san)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% return the stucture 'config' for fucntion 'PayBurstOnlyOnceMinimizing.m'
% based on the user determined arguments.
% Call:     config = ObtainConfig(wcets, tswons, tswoffs, step, activeNum,
%                   flp, N, n)
% Input:
%           alpha       the arrival curve of workload
%           deadline    the end to end, relative deadline of workload
%           wcets       the WCET vector of all the cores, having n elements
%           tswons      the t_swon vector of all the cores, having n elements
%           tswoffs     the t_swoff vector of all the cores, having n elements
%           step        step of the searching algorithm
%           activeNum   the number of actived cores 
%           flp         the structure of floorplan, containing the name of
%                       nodes, the size and location of nodes, and the
%                       distance between every node and node #1
%           N           the number of nodes
%           n           the number of cores
%           san         the called number of SA algorithm to solve pboo problem
% Output:
%           config      the stuct containing the configuration, which
%                       are:
%           actcoreIdx  the index of actived cores
%           isAct       indicates if the core is active
%           wcets       worst case execution time of the cores indexed by
%                       actcoreIdx
%           tswons      switch on overhead of the cores indexed by actcoreIdx
%           tswoffs     switch off overhead of the cores indexed by actcoreIdx
%           step        step of the searching algorithm
%           activeNum   the number of actived cores 
%           alpha       the arrival curve of workload
%           deadline    end to end deadline
%           N           node number, from thermal model
%           n           core number, from thermal model
%           flp         the floorplan struct 
%           san         the called number of SA algorithm to solve pboo problem
% author:   Long
% version:  1.0     16/11/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check inputs
if nargin < 10
    error('Inputs not enough');
end
if nargin < 11
    san = 1;
end   

[flag, ~] = checkingArguments(deadline, wcets, tswons, tswoffs, step, activeNum, flp, N, n);
if flag == 0
    error('input arguments error');
end

%% creat the return structure
config = struct('wcets', [], 'tswons', [], 'tswoffs', [], 'step', step,...
    'activeNum', activeNum, 'actcoreIdx', [], 'isAct', false(1, n),'alpha', alpha,...
    'deadline', deadline,'flp', flp, 'sumWcet', 0, 'sumTswoff', 0);


%% get the indexs of the active cores
% dist = flp.dist;
% activeCoreIdx = zeros(1, activeNum);
% for i = 1 : activeNum
%     idx = find(dist == min(dist), 1, 'first');
%     activeCoreIdx(i) = idx;
%     config.isAct(idx)= true;
%     dist(idx) = inf;
% end
% % sort the index, such that we can easily locate the cores
% activeCoreIdx = sort(activeCoreIdx);

activeCoreIdx = chooseActCores(flp, activeNum);
config.isAct(activeCoreIdx) = true;
config.actcoreIdx   = activeCoreIdx;

%% get the wcets, tswons, tswoffs of the actived cores

config.wcets        = shrinkVars(wcets, activeCoreIdx);
config.tswoffs      = shrinkVars(tswoffs, activeCoreIdx);
config.tswons       = shrinkVars(tswons, activeCoreIdx);

config.sumWcet      = sum(config.wcets);
config.sumTswoff    = sum(config.tswoffs);
config.sumTswon     = sum(config.tswons);
config.n            = n;   
config.san          = san;   