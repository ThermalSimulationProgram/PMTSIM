function [flag, report] = checkingArguments(deadlineORconfig, wcets, tswons, tswoffs, step, activeNum, flp, N, n)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check if there is any confict in the input arguments for the struct
% 'config'  
% Call: 
%   [flag, report] = checkingArguments(deadline, wcets, tswons, tswoffs, step, activeNum, flp, N, n)
%   OR
%   [flag, report] = checkingArguments(config)
% Input:
%   deadlineORconfig    is config when there is only one input argument,
%                       otherwise, is the deadline
%   wcets               the WCET vector of all the cores, having n elements
%   tswons              the t_swon vector of all the cores, having n elements
%   tswoffs             the t_swoff vector of all the cores, having n elements
%   step            	step of the searching algorithm
%   activeNum           the number of actived cores 
%   flp                 the structure of floorplan, containing the name of
%                       nodes, the size and location of nodes, and the
%                       distance between every node and node #1
%   N                   the number of nodes
%   n                   the number of cores  
% Output:
%   flag                1 when no confict, otherwise 0
%   report              report of checking
% author:       Long
% version:      1.0   17/11/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ( nargin < 9 && nargin > 1 ) || nargin == 0
    error('input arguments not enough');
end

if nargin == 1
    if ~isstruct(deadlineORconfig)
        error('input must be the struct ''config'' when there is only one input argument');
    end
    
    deadline    = deadlineORconfig.deadline;
    wcets       = deadlineORconfig.wcets;
    tswons      = deadlineORconfig.tswons;
    tswoffs     = deadlineORconfig.tswoffs;
    step        = deadlineORconfig.step;
    activeNum   = deadlineORconfig.activeNum;
    flp         = deadlineORconfig.flp;
    checkIndex  = [ 1:3, 7:9] ;
else
    deadline    = deadlineORconfig;
    checkIndex  = 1:14;
end


% initialize output
flag        = 1;
report      = 'Input arguments have no confict';
% table of error types
errorList   = { 'wcets should be a vector with positive elements', ...      %1
                'tswons should be a vector with positive elements', ...     %2
                'tswoffs should be a vector with positive elements', ...    %3
                'wcets should have the length ''n''',...                    %4
                'tswons should have the length ''n''',...                   %5
                'tswoffs should have the length ''n''',...                  %6
                'deadline must be a positive number',...                    %7
                'step must be a positive number',...                        %8
                'activeNum must be positive integer',...                    %9
                'N must be positive integer',...                            %10
                'n must be positive integer',...                            %11
                'nodes number N must be larger than core number n',...      %12
                'numer of actived cores must be less than ''n''',...        %13
                'wrong floorplan or wrong ''n'''...                         %14
              };
% table of judgements, correspondding to table of error types
judgements  = { '~isvector(wcets) || max(max(wcets <= 0))',...
                '~isvector(tswons) || max(max(tswons <= 0))',...
                '~isvector(tswoffs) || max(max(tswoffs <= 0))',...
                'length(wcets) ~= n',...
                'length(tswons) ~= n',...
                'length(tswoffs) ~= n',...
                'max(size(deadline)) > 1 || max(max(deadline <= 0)) ',...
                'max(size(step)) > 1 || max(max(step <= 0))',...
                'max(size(activeNum)) > 1 || activeNum <= 0  || max(max(floor(activeNum) ~= activeNum))',...
                'max(size(N)) > 1 || N <= 0 || max(max(floor(N) ~= N))',...
                'max(size(n)) > 1 || n <= 0 || max(max(floor(n) ~= n))',...
                'N <= n',...
                'activeNum > n',...
                'flp.num ~= n || min(flp.dist) < 0'...           
};


temp        = '';

error_amount = size(checkIndex, 2);

for i = 1 : error_amount
    id = checkIndex(i);
    if eval(judgements{id})
        if flag == 1
            temp = strcat( [ temp, errorList{id} ] );
        else
            temp = strcat( [ temp, '\n&\n', errorList{id} ] );
        end
        flag = 0;
    end
end

if flag == 0
    report = temp;
end

sprintf(report)
end


