function [toffs, tons, caseA_num, caseB_num] = newBTS(config)
%
%  INPUT:
%   activeSetIndex: the index of active set, 1*n
%   sleepSetIndex: the index of sleep set, 1*n
%   consistConstSet:Consistency Constant set
%   deadlineConstSet:Deadline Constant set
%   OUTPUT:
%   SleepInterval:Sleep Interval

activeSetIndex  = config.activeSet;
sleepSetIndex   = config.sleepSet;
nactiveStage    = numel(activeSetIndex);
nsleepStage     = numel(sleepSetIndex);
nstages         = nactiveStage + nsleepStage;
consistConstSet = config.ccs;
deadlineConstSet= config.dcs ;
TBET            = config.TBET ;
 alldata         = config.offlineData;
rho             = config.rho;
K               = config.K;
slopefuncs      = alldata.slopedata;

caseA_num = 0;
caseB_num = 0;

%% prepare reward functions for corresponding slopes
rewardfuncs = cell(1, nstages);
numslopes = numel(slopefuncs);
for i = 1 : nstages
    rhoi = K(i);
    rhoId = min(numslopes, max(1, round(rhoi/0.01)));
    rewardfuncs{i} = slopefuncs{rhoId}{i};
end
dynamicdata.rewardfuncs = rewardfuncs;
dynamicdata.wcets = config.wcets;
dynamicdata.rho = rho;
dynamicdata.deltaT = config.deltaT;

%%

%Algo 2
tau0 = zeros(1, nstages);
taue = zeros(1, nstages);
tons = taue;
%Algo 1
newActiveStagesIndex = activeSetIndex;
nactiveStage1       = size(newActiveStagesIndex,2);
activeSetT          = config.T(activeSetIndex);
% line 1
resultActiveIndex   = [];
resultSleepIndex    = [];
% line 2-3
resultSleepIndex    = [resultSleepIndex, sleepSetIndex];
tau0(sleepSetIndex) = consistConstSet;
%triangle matrix
% if(CurTime>70 && CurTime<71)
%     CurTime
% end
% lamda_bar = Reduce_Matrxi(newActiveStagesIndex, nactiveStage1, sleepSetIndex, ...
%     nsleepStage, consistConstSet, nsleepStage, deadlineConstSet, nstages);
lamda_bar = reduceM(newActiveStagesIndex, sleepSetIndex, deadlineConstSet, consistConstSet, nstages);
% if any(lamda_bar(:) ~= lambda_bar2(:))
%     warning('sd');
% end
if ~isempty(lamda_bar)
    phi = min( floor(lamda_bar ./ TBET(newActiveStagesIndex)),  1 : nactiveStage1);
else
    phi = [];
end
while(nactiveStage1 > 0)
    % find the mimimal phi and where is the minphi
    if isempty(phi)
        sss=1;
    end
    [minphi, indexAtminphi] = min(phi);
    %indexAtminphi = find( phi == minphi);
    % find how many active stages, at the minimal phi
    nstage2minphi = indexAtminphi(end);
    
    % get their index in newActiveStagesIndex
    stageIndex2minphi = (nactiveStage1 - nstage2minphi + 1) : nactiveStage1; 
    % get their index on the stage
    tempsetIndex = newActiveStagesIndex( stageIndex2minphi );
    
    % if we can switch any active stage to sleep
    if minphi > 0
        T0 = activeSetT( stageIndex2minphi );
        % sort temperature descendly, and get the corresponding index, so
        % the front one gets higher priority to switch off
        [~, index] = sort(T0,'descend'); 
        
        
        
        if( nstage2minphi > minphi )
            % put the end part stages to active set
            resultActiveIndex = [resultActiveIndex, tempsetIndex(index(minphi+1:end))];
        end
        % put beginning part stages to sleep set
        resultSleepIndex = [resultSleepIndex, tempsetIndex(index(1:minphi))];
        % set their sleep time to initial value
        tau0(tempsetIndex(index(1:minphi))) = TBET(tempsetIndex(index(1:minphi)));
    else
        % we cannot switch any stage to sleep, so all to active set
        resultActiveIndex = [resultActiveIndex, tempsetIndex];
    end
    
    % update phi and active set
    phi = phi(nstage2minphi + 1 : end) - minphi;
    nactiveStage1 = nactiveStage1 - nstage2minphi;
    newActiveStagesIndex = newActiveStagesIndex(1 : nactiveStage1);
    phi = min( phi,1 : nactiveStage1 );
end


ASS_N = numel(resultActiveIndex);
SSS_N = numel(resultSleepIndex);
%Algo 2
% sort them in formal order
[resultSleepIndex]    = sort(resultSleepIndex);
[resultActiveIndex]   = sort(resultActiveIndex);

% extend toffs of sleep stages as much as possible
if(SSS_N)
    ASS_N1 = ASS_N;
    SSS_N1 = SSS_N;
    SSS1 = resultSleepIndex;
    ASS1 = resultActiveIndex;
    lamda_bar_e = Reduce_Matrxi(SSS1, SSS_N1, ASS1, ASS_N1, ...
        zeros(1,ASS_N1), ASS_N1, deadlineConstSet, nstages);
    lamda_bar_e = lamda_bar_e -  (tril(ones( SSS_N1, SSS_N1)) * tau0(SSS1)')';
    
    
    while( SSS_N1 > 0 )
        
        minlamda    = min(lamda_bar_e);
        lamda_index = find(lamda_bar_e==minlamda);
        lamda_index = lamda_index(end);
        % get the stage index in this iteration
        tempsetIndex     = SSS1((SSS_N1-lamda_index+1):SSS_N1);
        if minlamda <= 0
        %    error('cannot extend');
        tinvs = zeros(size(tempsetIndex));
        tvlds = 100*ones(size(tempsetIndex));
        else
%         [lambdaExt] = assigToffs(minlamda, tempsetIndex, tau0(tempsetIndex),...
%             validData, numValidData);
dynamicdata.breakToffs = alldata.breakToffs(:,tempsetIndex);
dynamicdata.slopes = alldata.slopes(:,tempsetIndex);
dynamicdata.numValidData = alldata.numValidData(tempsetIndex);

[tinvs, tvlds, caseA_num1, caseB_num1] = aPtm(minlamda, tempsetIndex, tau0(tempsetIndex), dynamicdata);
caseA_num = caseA_num + caseA_num1;
caseB_num = caseB_num + caseB_num1;
        end
        taue(tempsetIndex) = tinvs;
        tons(tempsetIndex) = tvlds;
        %taue(tempsetIndex) = minlamda/lamda_index;
        
        lamda_bar_e   = lamda_bar_e( lamda_index+1 : SSS_N1)- minlamda;
        
        SSS_N1      = SSS_N1-lamda_index;
        SSS1        = SSS1(1:SSS_N1);
    end
    toffs = tau0 + taue;

    toffs = floor((toffs - config.tswons)/config.deltaT) * config.deltaT;
    toffs = max(toffs, 0);
else
    toffs = zeros(1, nstages);
    tons  = 100*ones(1, nstages);
end
tons = ceil((tons + config.tswons)/config.deltaT) * config.deltaT;

% tons = zeros(1, nstages);
% for i = 1 : nstages
%     if toffs(i) < 0
%         error('negative');
%     end
%     if config.rho(i) < 1e-5
%         tons(i) = 0;
%     else if config.rho(i) == 1
%             toffs(i) = 0;
%             tons(i) = 100;
%         else
%             tons(i) = config.rho(i) * toffs(i) / (1-config.rho(i)) + ...
%             config.tswons(i)/(1-config.rho(i));
%         end
%     end
% end

    
%     [newtinvs, newtvlds] = repairPTM(toffs+config.tswons, tons-config.tswons,...
%         config.rho, config.wcets, TBET + config.tswons, validData);
%     toffs = newtinvs - config.tswons;
%     tons = newtvlds + config.tswons;
% toffs = max(0, floor(toffs/config.deltaT) * config.deltaT);
% tons = ceil(tons /config.deltaT) * config.deltaT;

