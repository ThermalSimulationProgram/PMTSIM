function config = defaultConfig()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% return default stucture 'config' 
% 
% Call:     config = defaultConfig()
%                   
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
%
% author:   Long
% version:  1.0     06/03/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% default parameters
alpha = rtcpjd(100,0,0);
deadline = 100;
n = 8;
N = 44;
step = 2;
wcets = ones(1, n) * 10;
tswons = ones(1, n) * 1;
tswoffs = ones(1, n) * 1;
activeNum = 5;
flp = ARM8coresfloorplan();
san = 1;

config = ObtainConfig(alpha, deadline, wcets, tswons, tswoffs, step,...
    activeNum, flp, N, n, san);