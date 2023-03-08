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
% the max length of the sum 
MAXLENGTH  = 4E+07;

%%
size_n = size(timps,1);
periods = zeros(1, size_n);
tSrts = zeros(1, size_n);
for i = 1 : size_n
    if isempty( timps(i,1).p)
        % timps(i,1) is empty, no periodic wave inside
        continue;
    end
    periods(i) =  timps(i,1).tEnd - timps(i,1).tStart;
    tSrts(i) = timps(i,1).tStart;
end
tstart = max(tSrts);
validId = periods > 0;
validN = sum(validId);

if validN == 1
   ids = 1 : size_n;
   index = ids(validId);
   v = timps(index,1).vMax;
   return;
    
end


%%
% calculate the least common multiple of the periods
period_lcm = 2*nlcm( periods( periods>0 ),  0.001);
tEnd = tstart + period_lcm;

sampleLength = tEnd - tSrts(validId);
%%repnum = ceil( (tEnd - tSrts(validId)) ./ ( periods(validId) - 2*p));

periodLength = ceil(period_lcm/p);

scale = max(1, ceil(periodLength/MAXLENGTH));
lengthOfSum = ceil(periodLength/scale);
StartIds = (  round((tstart -  tSrts(validId)) / p / scale) + 1  )';
IDs = [ StartIds , StartIds + lengthOfSum - 1];
%%
S = zeros(1, lengthOfSum);
ids = 1:size_n;
valids = ids(validId);
for i = 1 : validN
    index = valids(i);
    C  = timps(index,1).imp([ fliplr( timps(index,1).idPeak:-scale:1 ),...
        timps(index,1).idPeak + scale : scale : end  ]);
    if length(C) > 1
    repnum = ceil( sampleLength(index) / ( ( length(C) - 1 )*p*scale ) );
    temp = repmat( C, 1, repnum);
    S = S+temp(IDs(index,1) : IDs(index,2) ); 
    else
     S = S + C;   
    end
end

v = max(S);

