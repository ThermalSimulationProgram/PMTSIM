function [lambdaExt] = assigToffs(upBound, index, tau0, breakToffs,...
    slopes, numValidData)
% how many toffs
nindex = numel(index);

% initial sum
sumLambda = sum(tau0);
% modify to the real upbound of toffs
upBound = upBound + sumLambda;
lambdaExt = tau0;
% simple case
if nindex == 1
    if  upBound < max(breakToffs)
        lambdaExt = upBound; 
    else
        lambdaExt = max(breakToffs);
    end
    lambdaExt = lambdaExt - tau0;
    return;
end

% the maximal number of segments
nsegments   = size(breakToffs, 1);
% index for current segements
segementId  = 1 : nsegments : nsegments*nindex;
segmentIdLim = segementId + numValidData - 1;


for i = 1 : nindex
    while breakToffs(segementId(i)) <= tau0(i) && segementId(i) <= segmentIdLim(i);
        segementId(i) = segementId(i) + 1;
    end
    
end

validId = segementId <= segmentIdLim; % to indicate if current toffs don't at end points  
while sumLambda < upBound
    nextBreakPoints = breakToffs(segementId);
    if all( isinf(nextBreakPoints) )
        break;
    end
    nextBreakPoints = nextBreakPoints(validId);
    dist2nextBP     = nextBreakPoints - lambdaExt(validId);
    currentSlope    = abs(slopes(segementId));
    currentSlope    = currentSlope(validId);
    K = sum(currentSlope) ./ currentSlope;
    [validDist]     = min(dist2nextBP(dist2nextBP>1e-10) .* K(dist2nextBP>1e-10));
    
    diff2UB = upBound - sumLambda;
    if validDist < diff2UB
        [b] = linearAssign(currentSlope, validDist);
        lambdaExt(validId) = lambdaExt(validId) + b;
        sumLambda = sumLambda + validDist;
        atBreakPointId = abs(lambdaExt - breakToffs(segementId)) < 1e-10;
        feasible = segementId < segmentIdLim;
        changeId = atBreakPointId & feasible;
        toInfId = atBreakPointId & ~feasible;
        segementId(changeId) = segementId(changeId) + 1;
       % breakToffs(:, toInfId) = inf; 
        validId = ~toInfId;% set this Id infeasible
       
    else
        [b] = linearAssign(currentSlope, diff2UB);
        lambdaExt(validId) = lambdaExt(validId) + b;
        break;
    end
    
    
end
end



function [b] = linearAssign(slopes, a)
b = slopes/sum(slopes)*a;
end