%** Made by (Gang Chen @TUM)
function SleepInterval = BWS_Dynamics(activeSetIndex, sleepSetIndex, consistConstSet, ...
    deadlineConstSet, TBET, Q, CurTime)
%
%  INPUT:
%   activeSetIndex: the index of active set, 1*n
%   sleepSetIndex: the index of sleep set, 1*n
%   consistConstSet:Consistency Constant set
%   deadlineConstSet:Deadline Constant set
%   OUTPUT:
%   SleepInterval:Sleep Interval
SleepInterval=[];
AS_N = size(activeSetIndex, 2);
SS_N = size(sleepSetIndex, 2);
M    =  AS_N + SS_N;
%Algo 2
tau0 = zeros(1,M);
taue = zeros(1,M);
%Algo 1
AS_Index1 = activeSetIndex;
SS_Index1 = sleepSetIndex;
AS_N1 = size(AS_Index1,2);
SS_N1 = size(SS_Index1,2);
M1    = AS_N1+SS_N1;
CCS1  = consistConstSet;
DCS1  = deadlineConstSet; 
Q1_A  = Q(activeSetIndex);
ASS = [];
SSS = [];
SSS = [SSS,sleepSetIndex];

tau0(sleepSetIndex) = consistConstSet;
%triangle matrix
if(CurTime==700)
    CurTime
end
lamda_bar = Reduce_Matrxi(AS_Index1, AS_N1, SS_Index1, SS_N1, CCS1, SS_N1, DCS1, M1);

if ~isempty(lamda_bar)
    fi = min(floor(lamda_bar ./ TBET(AS_Index1)), 1:AS_N1);
else
    fi = [];
end


%fi = min(floor(lamda_bar ./ TBET(AS_Index1)), 1:AS_N1);
while(AS_N1 > 0)
    minfi = min(fi);
    min_index = find(fi==minfi);
    min_index = min_index(end);
    tempset = AS_Index1((AS_N1-min_index+1):AS_N1);
    if(minfi)
        Q0 = Q1_A( (AS_N1-min_index+1):AS_N1 );
        [~,index] = sort(Q0);
        if( min_index>minfi )
            ASS = [ASS,tempset(index(minfi+1:end))];
        end
        SSS = [SSS,tempset(index(1:minfi))];
        tau0(tempset(index(1:minfi))) = TBET(tempset(index(1:minfi)));
    else
        ASS = [ASS,tempset];
    end
    fi = fi(min_index+1:end)-minfi;
    AS_N1 = AS_N1 - min_index;
    AS_Index1 = AS_Index1(1:AS_N1);
    fi = min(fi,1:AS_N1);
end
ASS_N = size(ASS,2);
SSS_N = size(SSS,2);
%Algo 2
[SSS,~] = sort(SSS);
[ASS,~] = sort(ASS);
if(SSS_N)
    ASS_N1 = ASS_N;
    SSS_N1 = SSS_N;
    SSS1 = SSS;
    ASS1 = ASS;
    lamda_bar_e = Reduce_Matrxi(SSS1,SSS_N1,ASS1,ASS_N1,zeros(1,ASS_N1),ASS_N1,DCS1,M1);
    
    lamda_bar_e = lamda_bar_e-tau0(SSS1)*rot90(tril(ones(SSS_N1,SSS_N1)));
    while(SSS_N1>0)
        minlamda    = min(lamda_bar_e);
        lamda_index = find(lamda_bar_e==minlamda);
        lamda_index = lamda_index(end);
        tempset     = SSS1((SSS_N1-lamda_index+1):SSS_N1);
        taue(tempset) = minlamda/lamda_index;
        lamda_bar_e   = lamda_bar_e(lamda_index+1:SSS_N1)-minlamda;
        SSS_N1      = SSS_N1-lamda_index;
        SSS1        = SSS1(1:SSS_N1);
    end
    SleepInterval = tau0+taue;
else
    SleepInterval = zeros(1,M);
end



