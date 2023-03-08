function [result] = PayBurstOnlyOnceMinimizing(TM, config, kernel)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find the minimal peak temperature for a pipeline
% multicore processor using pay burst only once.
%
% INPUT:
%       TM              thermal model
%       kernel          determines which approach is used by the algorithm
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
% OUTPUT:
%       optTemp         the minimal peak temperature
%       optsolution     the optimal solution for tons and toffs
%       opt_b           the optimal b
%       opt_rho         the rho corresponding to opt_b
% author:       Long 
% version:      1.0  31/10/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Checking input arguments
tt=tic;
if (nargin < 3)
    error('input arguments not enough');
end

[flag, report] = checkingArguments(config);
if flag == 0
    error(report);
end



% if ~strcmp(config.flp.name, TM.name)
%     error('floorplan doesn''t agree with the thermal model');
% end


%% some shortcuts
step        = config.step;
activeNum   = config.activeNum;

%% test all the possible values of b step by step
maxWcets    = max(config.wcets);
% demand service curve
beta        = rtcaffine(config.alpha(1), 1, config.deadline);
% find the feasible region of b
b_min       = config.sumWcet + config.sumTswoff + config.sumTswon;
minSlope    = 1 / maxWcets;
b_max       = minbdf_WCET(beta, 0 , minSlope);

if b_max <= b_min
    error('deadline too small');
end

% initialize
optTemp     = max(TM.T_inf_a);
optsolution = zeros(1, activeNum);
opt_b       = 0;
opt_rho     = 1;


for b = b_min : step : b_max
    %b   = 69.98;
    b
    
    rho= minspeedbdfEDG(beta, b, 1);
    if rho * maxWcets >= 0.98
        continue;
    end
%     if (b - TM.n/rho <= 0)
%         continue;
%     end
    dynamicData = makedata('b',b, 'rho',rho, 'kernel', kernel);
    [miniTpeak, solution] = PBOOsubStep(dynamicData, config, TM);
    if miniTpeak < optTemp
        optTemp = miniTpeak;
        optsolution = solution;
        opt_b = b;
        opt_rho = rho;
    end
end
exetime = toc(tt);
result = results(opt_b,opt_rho,optTemp,optsolution,kernel,config.activeNum,...
        exetime);

