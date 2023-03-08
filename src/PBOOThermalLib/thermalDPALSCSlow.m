function [result] = thermalDPALSCSlow(TM, config)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find the minimal peak temperature for a pipeline
% multicore processor without using pay burst only once.
%
%INPUT:
%       TM              thermal model
%       config          specified configuration list, including: 
%           actcoreIdx  the index of actived cores
%           wcets       worst case execution time of the cores in
%                       actcoreIdx
%           tswons      switch on overhead of actived cores 
%           tswoffs     switch off overhead of actived cores
%           step        step of the searching algorithm
%           activeNum   the number of actived cores 
%           alpha       the arrival curve of workload
%           deadline    end to end deadline
%           N           node number
%           n           core number
%           flp         A struct describing the floorplan
%
%OUTPUT:
%       optTemp         the minimal peak temperature
%       optsolution     the optimal solution for tons and toffs
%       optpartition    the optimal solution for deadline partition
%  finished by Long 03/07/2015
%  version 2.0 01/02/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check input arguments
tt =tic;
if (nargin<2)
    error('input arguments not enough');
end

[flag, report] = checkingArguments(config);
if flag == 0
    error(report);
end

%% shortcuts
n           = TM.n;
p           = TM.p;
sumWcet     = config.sumWcet;
tswoffs     = config.tswoffs;
tswons      = config.tswons;
wcets       = config.wcets;
sumTswon    = sum(config.tswons);
acn         = config.activeNum;
coreIdx     = config.actcoreIdx;
step        = config.step;
scalor1     = 0.001; % the unit of toff and ton, scale between ms and s
pToffTon    = p / scalor1; 
deadline    = config.deadline;
Timp        = ImpulsePeriod2dMat(n, n);

%% initialize output
optTemp     = max(TM.T_inf_a);
optsolution = zeros(2, n);
optpartition = zeros(1, n);

%% pre-processing
feasibleDeadline = zeros(acn,2);
for i = 1 : acn
    feasibleDeadline(i, 1) = wcets(i) + tswons(i);
    feasibleDeadline(i, 2) = deadline - ( sumWcet + sumTswon - wcets(i) - tswons(i));
end

% get the deadline candidcates for every core
candidDeadline = cell(1, acn-1);
limit          = zeros( size(candidDeadline));
for i = 1 : acn-1
    % deadline candidcates
    candidDeadline{i} = feasibleDeadline(i, 1) : step : feasibleDeadline(i, 2);
    limit(i)          = size( candidDeadline{i}, 2 );
end

if min(limit)<1
    error('deadline too small');
end

% initialize the deadline index as [1,1,....,1]
deadlineIdx = ones(1, acn - 1);

% predict the number of total loops
total = 1;
for i = 1 : acn - 1
    total = total * limit(i);
end
% a counter
count = 0;
%% continuely updating the deadline index and calculate the peak temperature

stop = 0;
isFast = false;
while ~stop
    
    % the deadline partition for current deadline index
    partition = zeros(1, acn);
    for i = 1 : acn-1
        partition(i) = candidDeadline{i}( deadlineIdx(i) );
    end
    partition(acn) = deadline - sum( partition(1 : acn-1) );
    
    % check if feasible
%     if partition(n) >= feasibleDeadline(TM.coreIdx(n), 1) &&...
%             partition(n) <= feasibleDeadline(TM.coreIdx(n), 2) % not feasible
        % update the deadline index
        
        % feasible
        % the feasible region of toffs
        fesibleToff = zeros(acn,2);
        %cand = cell(1,n);
        for j= 1 : acn
            fesibleToff(j,1) = tswoffs(j) + p;
            fesibleToff(j,2) = partition(j) - wcets(j) - tswons(j);
           % cand{j} = fesbl(j,1) : step :fesbl(j,2);
        end
        
        
        alpha_in = config.alpha;
        toffs = zeros(1, acn);
        tons  = zeros(1, acn);
        
        for k = 1 : acn
            
            %construct the demand service bound
            alpha_deadline = rtcaffine( alpha_in(1), 1 , partition(k));

            %for current core, k, we get the best toff and  ton where the peak
            %temprature when this core is actived is the
            %minimum
            [optToff, optTon, feasible, Timp] = DPAPTM(alpha_deadline, ...
                fesibleToff(k,:), k, TM, Timp, config);
            
            if feasible == 0 % no solution is found
                break;
            end
            toffs(k) = optToff;
            tons(k) = optTon;
            if k < acn
                % calculate the output arrival curve for the next core
                tvld = max(round(tons(k) - tswons(k)), 1);
                beta = rtctdma( tvld, round(tons(k) + toffs(k)) , 1);
                bli = beta(2);
              %  bui = beta(1);
                bli = rtcrdivide(bli, wcets(k));
               % bui = rtcrdivide(bui, wcets(id));
                %save rtc bli alpha_in
                alpha_out = rtcmindeconv(alpha_in(1),bli);
                %alpha_out=rtcceil(rtcmin(rtcmindeconv(rtcminconv(alpha_in(1), bui), bli), bui)); 
                alpha_in = alpha_out;
            end
        end
        
        %         calculate tact and tslp for temperature calculating
        %         unit: msec
        if feasible
            [tact, tslp, tons]= prepareTacts(toffs, tons, config, false);
            [Tpeak, Timp] = CalculatePeakTemperatureV1(isFast, TM, tslp, tact, Timp,'global',[]);
            if Tpeak < optTemp
                optTemp = Tpeak;
                optsolution = [toffs; tons];
                optpartition = partition;
            end
        end
        
   % end
    
    % update the deadline index
    [deadlineIdx, flag] = updateIndex(acn-1, limit, deadlineIdx);
    count = count +1
    total
    if flag
        stop = 1;
    end
end
optsolution = [optsolution;optpartition];
exetime = toc(tt);
result = results(1,0.1,optTemp,optsolution,3,config.activeNum,...
        exetime);





