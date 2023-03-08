function [toffs, T] = tempCurveAtSlopeFastVersion(TM, tswons, tswoffs, slope, step)


if nargin < 4
    step = [];
end

if isempty(step)
    step = 2;
end

try
    if ~all(TM.isComplete)
        error('not complete');
    end
catch
    error('The thermal model is not complete');
end

m       = TM.n;
toffs   = cell(1,m);
T       = cell(1, m);
stopFactor = 2000;
maxiteration = 250;
for i = 1 : m
    minToff = tswoffs(i) * 2;  
    toffvec = zeros(1,m);
    go = 1;
    temptoff = [];
    tempT = [];
    
    toffvec(i) = minToff;
    tonvec = zeros(1,m);
    accuFactor = 0;
    counter = 0;
    while go && counter < maxiteration
        
        tonvec(i) = slope*toffvec(i)/(1-slope) + tswons(i)/(1-slope) + ...
            tswoffs(i);
        
        tact = tonvec ;
        tslp = toffvec;
        tslp(i) = tslp(i) - tswoffs(i);
        
        [peakT, ~, TM] = CalculatePeakTemperatureV2(0, TM, tslp, tact, []);
        
        
        
        temptoff = [temptoff, toffvec(i)];

        if ~isempty(tempT) 
            if peakT > tempT(end)
                accuFactor = accuFactor + 1;
            else
                accuFactor = 0;
            end
            
        end
        tempT = [tempT, peakT];
        
        if accuFactor > stopFactor
            go = 0;
        end
        toffvec(i) = toffvec(i) + step;
        counter = counter + 1;
        disp(sprintf('The %dth stage with toff = %f, slope = %f', i , toffvec(i), slope));
    end
    
    toffs{i} = temptoff;
    T{i} = tempT;
    
end





