function [miniTpeak solution] = findTheOptSolutionBrutally(TM, config, dynamicData)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function computes the best toff and ton by seaching all
% the possible solutions.

%% shortcuts
candids         = dynamicData.candids;
limit           = dynamicData.limit;
b               = dynamicData.b;
Timp            = dynamicData.Timp;
n               = TM.n;
acn             = config.activeNum;  % active core number
solution        = zeros(2,n);
miniTpeak       = max(TM.T_inf_a);
candidToffs     = candids.candidToffs;
candidTons      = candids.candidTons;
oldIndex        = ones(1, acn); % oldIndex(i) determined which toff in candidToffs{i} is currently
                                % choosed
optIndex        = zeros(1, acn);


limitSumToffs = dynamicData.SumBound;

%% display arguments
total = 1;
for i = 1 : acn
    total = total * limit(i);
end
count = 0;
tick = 0.1;
%% do the searching
stop = 0;
while ~stop
    
     [toffs, ~] = getPTMs(candids, oldIndex);
    
    % check if current toffs satisfy the deadline bounds
    if sum(toffs) > limitSumToffs
        [oldIndex, flag] = updateIndex(acn, limit, oldIndex);
        count = count +1;
        if flag
            stop = 1;
        end
        % display
        if count/total > tick
            count/total
            tick = tick + 0.1;
        end
        continue;
    end
    
    % get current peak temperature
    [peakTem, ~] = inquirePeakT(TM, config, Timp, candids, oldIndex);

    % update result
    if peakTem < miniTpeak
        miniTpeak = peakTem;
        optIndex = oldIndex;
    end
    
    % update current toffs, go to next point
    [oldIndex, flag] = updateIndex(acn, limit, oldIndex);
    
    
    count = count +1;
    
    if count/total > tick
            count/total
            tick = tick + 0.1;
    end
        
    
    % entire space explored
    if flag
        stop = 1;
    end   
end

% prepare results
if ~any( optIndex == 0 )
    for i = 1 : acn
        solution(1,i) = candidToffs{i}(optIndex(i));
        solution(2,i) = candidTons{i}(optIndex(i));
    end
end