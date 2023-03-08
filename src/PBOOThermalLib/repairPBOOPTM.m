function [miniT, solution] = repairPBOOPTM(TM, config, dynamicData, solution)

n           = config.activeNum;
actcoreIdx  = config.actcoreIdx;
wcets       = config.wcets;
tons        = solution(2,actcoreIdx) - config.tswons;
toffs       = solution(1,actcoreIdx) + config.tswons;
k           = wcets * dynamicData.rho;
isFast      = false;
Timp        = dynamicData.Timp;
alln        = TM.n;

budget = zeros(1,n);
slope = zeros(1,n);
step = 0.2;
for i = 1 : n
    id = actcoreIdx(i);

    if tons(i) < wcets(i)
        tons(i) = wcets(i);
    else
        tons(i) = floor(tons(i) / wcets(i)) * wcets(i);
        if tons(i)/k(i) - tons(i) < config.tswons(i)
            tons(i) = ceil(tons(i) / wcets(i)) * wcets(i);
        end
    end
    budget(i) = toffs(i) - (tons(i)/k(i) - tons(i));
    if budget(i) >= 0 % toff gets smaller
        toffs(i) = tons(i)/k(i) - tons(i);
    else % toff should get bigger
       
        slope(i) = getSlope(toffs, tons, id);
    end
    
end
if any(slope > 0)
    error('not correct');
end
Q = sum(budget(budget > 0));

while Q > 0
    [~, ic] = min(slope);
    if budget(i) < 0
        allo = min(Q, abs(budget(i)));
        toffs(ic) = toffs(ic) + allo;
        budget(i) = budget(i) + allo;
        slope(ic) = getSlope(toffs, tons, actcoreIdx(ic));
        Q = Q - allo;
        
        
    else
        
        break
    end
    
    
end



toffs = toffs - config.tswons;
tons  = tons + config.tswons;
tactfinal = tons + config.tswoffs;
tslpfinal = toffs - config.tswoffs;
tact2 = zeros(1, alln);
tslp2 = tact2;
tact2(actcoreIdx) = tactfinal;
tslp2(actcoreIdx) = tslpfinal;
[miniT, Timp, ~] = CalculatePeakTemperatureV3(isFast, TM, tslp2, tact2, Timp);
solution(1,actcoreIdx) = toffs;
solution(2,actcoreIdx) = tons;


function slope2 = getSlope(toffs, tons, index)
    tact = zeros(1, alln);
    tslp = tact;
    tact1 = tons + config.tswons + config.tswoffs;
    tslp1 = toffs - config.tswons - config.tswoffs;
    tact(actcoreIdx) = tact1;
    tslp(actcoreIdx) = tslp1;
    [beforeChange, Timp, ~] = CalculatePeakTemperatureV3(isFast, TM, tslp, tact, Timp);
    tslp(index) = tslp(index) + step;
    [afterChange, Timp, ~] = CalculatePeakTemperatureV3(isFast, TM, tslp, tact, Timp);
    slope2 = (afterChange - beforeChange)/step;
end

end







