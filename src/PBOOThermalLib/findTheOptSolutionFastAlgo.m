function [miniTpeak, solution] = findTheOptSolutionFastAlgo(TM, config, candids, limit, b, Timp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


n   = TM.n;
acn = config.activeNum; % active core number
solution = zeros(2,n);

candidToffs = candids.candidToffs;
candidTons = candids.candidTons;
globalOptIndex = zeros(1, acn);
isFast = true;

%% 
for toffId = 1 : acn
    tslp = zeros(1, TM.n);
    tact = zeros(1, TM.n);
    id = config.actcoreIdx(toffId);
    miniTpeak = max(TM.T_inf_a);
    localOptIndex = 1;
    for index = 1 : limit(toffId)
        tslp(id) = candids.candidTslps{toffId}(index);
        tact(id) = candids.candidTacts{toffId}(index);
        [peakTem, ~] = CalculatePeakTemperatureV2(isFast, TM, tslp, tact, Timp);
        if peakTem < miniTpeak
            miniTpeak = peakTem;
            localOptIndex = index;
        end
    end
    globalOptIndex(toffId) = localOptIndex;
    
end

%%
toffs = zeros(1, acn);

limitSumToffs = b - config.sumWcet;
for i = 1 : acn
    toffs(i) = candidToffs{i}(globalOptIndex(i));
end

%%
if sum(toffs) > limitSumToffs
   
    
    stop = 0;
    oldIndex = globalOptIndex;
    
    [currentTemp, ~] = inquirePeakT(TM, config, Timp,...
                candids, oldIndex);
    while ~stop
        
        
        grd = inf*ones(1, acn);
        
        if sum(oldIndex) <= acn
            miniTpeak = currentTemp;
            globalOptIndex = oldIndex;
            break;
        end
        
        % calculate grd
        for i = 1 : acn
            if oldIndex(i) <= 1
                continue;
            end
            nextIdx1 = oldIndex;
            nextIdx2 = oldIndex;
            nextIdx1(i) = oldIndex(i) - 1;
            % adopt a longer step to filter the tiny peak at next point, if it exists
            nextIdx2(i) = max(1, oldIndex(i) - 3);
            [nextTemp1, ~] = inquirePeakT(TM, config, Timp,...
                candids, nextIdx1);
            [nextTemp2, ~] = inquirePeakT(TM, config, Timp,...
                candids, nextIdx2);
            grd(i) = min(nextTemp1,nextTemp2) - currentTemp;
        end
        
        currentTemp = currentTemp + min(grd);
        changeIdx = find( grd == min(grd), 1, 'first' );
        oldIndex(changeIdx) = oldIndex(changeIdx) - 1;
        for i = 1 : acn
            toffs(i) = candidToffs{i}(oldIndex(i));
        end
        
        if sum(toffs) <= limitSumToffs
            miniTpeak = currentTemp;
            globalOptIndex = oldIndex;
            stop = 1;
        end
  
    end
    
    
end

if ~any( globalOptIndex == 0 )
    for i = 1 : acn
        solution(1,i) = candidToffs{i}(globalOptIndex(i));
        solution(2,i) = candidTons{i}(globalOptIndex(i));
    end
end
[miniTpeak, ~] = inquirePeakT(TM, config, Timp,...
                candids, globalOptIndex);
end
    
    
