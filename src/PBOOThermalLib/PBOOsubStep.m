function [miniTpeak, solution] = PBOOsubStep(dynamicData, config, TM)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% solve the problem of finding the minimal peak
% temperature for a multi-core platform with the given
% searching space by adopting pay burst only once.
% This is a subproblem of the PBOO problem.
%
% INPUT:
%  dynamicData:
%       b and rho:      boundaries of the searching space
%       kernel:         the kernel used to solve pboo sub problem
%
%       config          a struct containing configuration information of
%       tasks, containing
%           actcoreIdx  the index of actived cores
%           wcets       worst case execution time of the cores indexed by
%                       actcoreIdx
%           tswons      switch on overhead of the cores indexed by actcoreIdx
%           tswoffs     switch off overhead of the cores indexed by actcoreIdx
%           step        step of the searching algorithm
%           activeNum   the number of actived cores 
%           alpha       the arrival curve of workload
%           deadline    end to end deadline
%           N           node number
%           n           core number
%           flp         the floorplan struct 
%
%       TM              the thermal model, members are:
%       lc_a/lc_i       linear coefficient of DE in active/idel mode
%       ua/ui           the vector of the constant of DE in active/idle mode
%       initT           the initial temperature
%       fftH            the fourier transform of impulse response of the thermal LTI system.
%                       should be a N times N matrix
%       T_inf_a         the state steady temperature in active mode
%       coreIdx         indicates which nodes are cores.
%       p               resolution of time vector
%       tend            tend(i,j) indicates where H( ,i,j) becomes 0
%       isCore          if node(i) is (or not) a core, 1 / 0
%       Tconstmax       the constant impulse from non-core nodes
%       n               number of processing components
%       N               number of nodes
%       sizet           the length of time vector.
%
% OUTPUT:
%       miniTpeak       the minimal peak temperature
%       solution        the optimal solution of toffs and tons
%
% author: Long Cheng
% version 1.0:
%       2015-06-24: created
% version 2.0:
%       2015-07-12:
%       reduce the complexity. remove the part computing thermal model.
%       add the input check
%       2015-07-14: introduce structure TASK
% version 3.0:
%       2015-10-31:
%       1. change the algorithm which calculates the peak temperature
%       2. now we can switch among three kernels
%       3. replace input argument 'TASK' with structure 'config', re-arrange
%          the code structure to strength the software modularity
%       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% input check and initialize
rho         = dynamicData.rho;
b           = dynamicData.b;
kernel      = dynamicData.kernel;
if rho * max(config.wcets) >= 0.99
    error('PBOOsubStep: I can''t find a solution to tons. \rho is too large');
end

if ~( kernel == 1 || kernel == 0 || kernel == 2 )
    error('kernel should be 2, or 1, or 0');
end

%% shortcuts
p           = TM.p;
scalor      = 0.001; % the unit of toff and ton is ms, scale between ms and s
pToffTon    = p / scalor;  %% the resolution of toff and ton, unit ms
K           = rho * config.wcets;
SumBound    = b - config.sumWcet  - config.sumTswon;

dynamicData.pToffTon = pToffTon;
dynamicData.scalor = scalor;
dynamicData.K   = K;
dynamicData.rho = rho;
dynamicData.SumBound = SumBound;

if kernel == 2
    dynamicData.isSA = true;
else
    dynamicData.isSA = false;
end

%% determine the feasible region of toffs

dynamicData = getfeasibleRegion(dynamicData, config, TM);


%% prepare candidates of toff and ton for brutally searching
dynamicData = prepareCandids(dynamicData, config);


%% prepare the Timp of candidate toffs, which is used as a lookup table
dynamicData = prepareCandidTimp(dynamicData, config, TM);


%% sloving
switch kernel
    case 0
        [miniTpeak, solution] = findTheOptSolutionBrutally(TM, config, dynamicData);
    case 1
        [miniTpeak, solution] = findTheOptSolutionByGradient2(TM, config, dynamicData);
    case 2
        disp('start SA');
        miniTpeak = inf;
        for i = 1 : config.san
            [s, T , ~ , ~] = PBOOSA(TM, config, dynamicData);
            if T < miniTpeak
                miniTpeak = T;
                solution = s;
            end
        end
        
end


[miniTpeak, solution] = repairPBOOPTM(TM, config, dynamicData, solution);


delete(dynamicData.Timp);
clear dynamicData;













% 
% for actId = 1 : acn
%     
%     j = coreIdx(actId);
% 
%     Pa      = TM.ua(j);                                                  % DE constant in active
%     Pi      = TM.ui(j);
% 
%     for k = 1 : limit(actId)
%         
%         atact = candidTacts{actId}(k);
%         atslp = candidTslps{actId}(k);
%         
%         isAct = (atact >= pToffTon);  % same unit: ms
%         isPeriodic = (atact >= pToffTon && atslp >= pToffTon);
%         
%         if ~isAct || ~isPeriodic
%             continue;
%         end
%         %extend more 4 periods for robustness, unit: s
%         
%         % unit: s
%         [origin_ptrace, periodSamplePoints, ~] = ObtainPeriodicPowerTrace(Pa,...
%             Pi, atact*scalor1, atslp*scalor1, tracelength, p);
%         origin_ptrace = origin_ptrace(1:TM.sizet);
%         for target = 1 : acn
%             i = coreIdx(target);
%             
%             % get the interval for fft, 3 periods
%             sampleStart     = floor( TM.tend(i, j) / p );
%             local_maxIndex  = sampleStart + periodSamplePoints * 3;
%             % do fft
%             out             = ifft( TM.fftH(:, i, j) .*...
%                 fft(    datawrap(origin_ptrace,  fftLength)', fftLength) ) * p;
%             out_trace       = out(sampleStart : local_maxIndex);
%             clear out;
%             
%             % extract one period to creat an object of class PeriodSample
%             min3            = min( out_trace( ...
%                 end - 2*periodSamplePoints : end - periodSamplePoints ) );
%             min_id3         = find(out_trace(...
%                 end - 2*periodSamplePoints : end - periodSamplePoints) == min3, 1);
%             idx_start_time  = min_id3 + periodSamplePoints;
%             start_time      = (idx_start_time + sampleStart - 1) * p;
%             imp             = out_trace(idx_start_time : idx_start_time + periodSamplePoints);
%             
%             impulse         = PeriodSample();
%             psPush(impulse, imp', p, start_time);
% 
%             ImpMatAppendToff(Timp, i, j, atslp, atact, impulse);
%             
%         end        
%     end
% end

