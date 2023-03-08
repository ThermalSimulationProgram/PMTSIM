function [optT, solution] = findTheOptSolutionByGradient2(TM, config, dynamicData)


candids = dynamicData.candids;
limit   = dynamicData.limit;
b       = dynamicData.b;
Timp    = dynamicData.Timp;
K       = dynamicData.K;
scalor  = dynamicData.scalor;
n       = TM.n;
acn     = config.activeNum;
step    = config.step;
oldIndex = ones(1, acn);
stop    = 0;
minstep = TM.p/scalor;
isFast = false;

limitSumToffs =dynamicData.SumBound;
count1 = 0;
safeStep = safePeriod(K, TM.p/ scalor);
[toffs, ~] = getPTMs(candids, oldIndex);
[tact, tslp]= prepareTacts(toffs, K, config);
[currentTemp, Timp, ~] = CalculatePeakTemperatureV3(isFast, TM, tslp, tact, Timp);
while ~stop
    
    % [currentTemp, ~] = inquirePeakT(TM, config, Timp, candids, oldIndex);
    
    
    if sum(toffs) + step <= limitSumToffs
        [grd, currentTemp, Timp] = getGradient(currentTemp, TM, config, toffs, K, Timp, step,safeStep);
        if min(grd) >= 0
            step = step * 0.618;
            %existFlag = 1;
            %optIndex  = oldIndex;
        else
            %step = step;
            changeIdx = find( grd == min(grd), 1, 'first' );
            oldIndex(changeIdx) = oldIndex(changeIdx) + 1;
            toffs(changeIdx) = toffs(changeIdx) + step;
            [tact, tslp]= prepareTacts(toffs, K, config);
            [currentTemp, Timp, ~] = CalculatePeakTemperatureV3(isFast, TM, tslp, tact, Timp);
        end
        
        
        if step <= minstep
            stop = 1;
        end
        
    else
        
        % the upper bound of the toffs sum is reached. In this case, we
        % increase one step of one toff and decrease one step of another
        % toff except the toff whose index is previously changed, since this
        % case has already been checked in last iteration
        maxstep = limitSumToffs - sum(toffs);
        step = maxstep * 0.618;
        [grd, currentTemp, Timp] = getGradient(currentTemp, TM, config, toffs, K, Timp, step,safeStep);
        if min(grd) >= 0
            maxstep = limitSumToffs - sum(toffs);
            step = maxstep * 0.618;
            %existFlag = 2;
            %optIdx  = oldIndex;
        else
            changeIdx = find( grd == min(grd), 1, 'first' );
            oldIndex(changeIdx) = oldIndex(changeIdx) + 1;
            toffs(changeIdx) = toffs(changeIdx) + step;
            [tact, tslp]= prepareTacts(toffs, K, config);
            [currentTemp, Timp, ~] = CalculatePeakTemperatureV3(isFast, TM, tslp, tact, Timp);
        end
        
        
        if step <= minstep
            stop = 1;
        end
        
    end
    count1 = count1 + 1
end

%isFast = false;
% switch  existFlag
%     case 1
%         count2 = 0;
%         stop = 0;
%         step = 0.5*step;
%         minstep = TM.p/scalor;
%         while ~stop
%            [grd, currentTemp, Timp] = getGradient(currentTemp, TM, config, toffs, K, Timp, step,safeStep);
%            if min(grd) >= 0
%                step = 0.5*step;
%            else
%                changeIdx = find( grd == min(grd), 1, 'first' );
%                oldIndex(changeIdx) = oldIndex(changeIdx) + 1;
%                toffs(changeIdx) = toffs(changeIdx) + step;
%                step = 1.2*step;
%                [tact, tslp]= prepareTacts(toffs, K, config);
%                currentTemp = CalculatePeakTemperatureV3(isFast, TM, tslp, tact, Timp);
%
%            end
%
%            if step <= minstep
%                stop = 1;
%            end
%
%
%     count2 = count2 + 1
%         end
%
%
%
%     case 2
%
%         stop = 0;
%         count2 = 0;
%         minstep = TM.p/scalor;
%         maxstep = limitSumToffs - sum(toffs);
%         step = 0.5*maxstep;
%         while ~stop
%            [grd, currentTemp, Timp] = getGradient(currentTemp, TM, config, toffs, K, Timp, step,safeStep);
%            if min(grd) >= 0
%                step = 0.5*step;
%            else
%                changeIdx = find( grd == min(grd), 1, 'first' );
%                oldIndex(changeIdx) = oldIndex(changeIdx) + 1;
%                toffs(changeIdx) = toffs(changeIdx) + step;
%                maxstep = limitSumToffs - sum(toffs);
%                [tact, tslp]= prepareTacts(toffs, K, config);
%                currentTemp = CalculatePeakTemperatureV3(isFast, TM, tslp, tact, Timp);
%                step = 0.5 * maxstep;
%            end
%
%            if step <= minstep || maxstep <= minstep
%                stop = 1;
%            end
%            count2 = count2 + 1
%
%         end
%
%
%
% end








optT = currentTemp;
solution=zeros(2, n);
[~, ~, tons]= prepareTacts(toffs, K, config);

toffs = retrieveVars(toffs, config.actcoreIdx, n);
tons = retrieveVars(tons, config.actcoreIdx, n);
solution(1,:) = toffs;
solution(2,:) = tons;
%  for i = 1 : acn
%         solution(1,i) = candidToffs{i}(optIndex(i));
%         solution(2,i) = candidTons{i}(optIndex(i));
%     end
%




end




%         % the upper bound of the toffs sum is reached. In this case, we
%         % increase one step of one toff and decrease one step of another
%         % toff except the toff whose index is previously changed, since this
%         % case has already been checked in last iteration
%         tempT = max(TM.T_inf_a);
%         direction = zeros(acn*acn, acn);
%         for i = 1 : acn % the increased one
%
%             if oldIndex(i) + 1 > limit(i)
%                 continue;
%             end
%             for j = 1 : acn % the decreased one
%                 if j == i
%                     continue;
%                 end
%
%                 if oldIndex(j) - 1 < 1
%                     continue;
%                 end
%
%                 direction(i*j, i) = 1;
%                 direction(i*j, j) = -1;
%             end
%         end
%
%         [grd, currentTemp, Timp] = getGradient(currentTemp, TM, config,...
%             toffs, K, Timp, step, direction);
%
%         if min(grd) >= 0
%             stop = 1;
%             optIndex  = oldIndex;
%         else
%             currentTemp = tempT;
%             optId = find(grd == min(grd), 1, 'first' );
%             optdirection = direction(optId,:);
%             oldIndex = oldIndex +  optdirection;
%         end
