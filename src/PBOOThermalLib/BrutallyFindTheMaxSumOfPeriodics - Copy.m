function [v] = BrutallyFindTheMaxSumOfPeriodics(timps, p)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find the maximum of the sum of several periodic waves
% Input:
%       p       resolution
%       timps   the vector contaings wave objects
% Output:       
%       max     the maximum of the sum
%
% version:      1.0     04/11/2015
%               2.0     28/01/2016  fix bugs, polish codes
% author:       Long Cheng
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% 


size_n = size(timps,1);

W = zeros(size_n, 5);

periods = zeros(1, size_n);


n  = 0;
valids = zeros(1, size_n);

for i = 1 : size_n
    
    if isempty( timps(i,1).p)
        % timps(i,1) is empty, no periodic wave inside
        continue;
    end
%       W       the matrix specifying the periodic waves. W(i,1)
%               the start time of one period of wave i;
%               W(i,2) the time of the peak; W(i,3) the end time; W(i,4)
%               the minimum in one period; W(i,5) the maximum.
    W(i,:)   = [timps(i,1).tStart, timps(i,1).tPeak, timps(i,1).tEnd,...
                 timps(i,1).vMin, timps(i,1).vMax];
    W = round( W / p ) * p ;
    n = n + 1;
    valids(n) = i;  % a vector containing the ids of all valid timps
    periods(n) =  W(i,3) - W(i,1);
    if periods(n) <= 0
        error('period must be positive');
    end
end

%%
% calculate the least common multiple of the periods
period_lcm = nlcm( periods( periods>0 ),  p);

% the max length of the sum 
MAXLENGTH  = 4E+06;
scale = 1;
if period_lcm/p <= MAXLENGTH
    % the length of lcm period with resolution p is smaller than MAXLENGTH,
    % we use period_lcm/p
    lengthOfSum = ceil(period_lcm/p);
else
    % otherwise, we use MAXLENGTH, all the sample vectors have to be scaled
    % in time 
    scale = ceil(period_lcm/p/MAXLENGTH);
    lengthOfSum = ceil(period_lcm/p/scale);
end

%%
tstart  = max( W(:, 1) );
sum = zeros(1, lengthOfSum);
for i = 1 : n
    index = valids(i);
    if scale > 1
        B  = length( timps(index,1).imp );
        % scale in time 
        id = 1 : scale : B;
        C  = timps(index,1).imp(id);
    else
        C  = timps(index,1).imp;
    end
    repnum = ceil( (tstart - W(i,1)) / periods(i) ) + ceil( period_lcm / periods(i) );
    temp = repmat( C, 1, repnum);
    startIdx = round((tstart -  W(i,1)) / p) + 1;
    sum = sum + temp(startIdx : startIdx + lengthOfSum - 1 );   
end

v = max(sum);

