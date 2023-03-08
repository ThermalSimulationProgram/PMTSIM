function [toffs, T] = tempCurveAtSlope(pipeline, slope, step, simLengthFactor)

if nargin < 4
    simLengthFactor = [];
end
if nargin < 3
    step = [];
end

if isempty(step)
    step = 2;
end

if isempty(simLengthFactor)
    simLengthFactor = 150;
end

m       = pipeline.nstage;
toffs   = cell(1,m);
T       = cell(1, m);
startTime = 0;
stopFactor = 300;
for i = 1 : 1
    
    minToff = pipeline.coreArray(i).tswoff * 2;  
    toff = minToff;
    go = 1;
    temptoff = [];
    tempT = [];
    
    accuFactor = 0;
    while go
        origPipeline = pipeline;
        ton = slope*toff/(1-slope) + origPipeline.coreArray(i).tswon/(1-slope);
        setlength = 0*simLengthFactor * (ton + toff) + 200000;
        runEndTime = startTime + setlength;
        origPipeline.coreArray(i) = getPTMcTrace(origPipeline.coreArray(i), setlength,...
            ton, toff);
        
        
        for j = 1 : m
            if j == i
                continue;
            end
            origPipeline.coreArray(j) = getPTMcTrace(origPipeline.coreArray(j), setlength,...
                0, toff);
        end
        
        for j = 1 : m
            % run the cores 
            [origPipeline.coreArray(j)] = runCore(origPipeline.coreArray(j),...
                startTime, runEndTime);
        end
        % calculate the temperature
        origPipeline = dynamicTem(origPipeline);
        
        temptoff = [temptoff, toff];
        peakT = max(origPipeline.T);
%         if ~isempty(tempT) 
%             if peakT > tempT(end)
%             accuFactor = accuFactor + 1
%             else
%                 accuFactor = 0
%             end
%             
%         end
        tempT = [tempT, peakT];
        
        if toff > stopFactor
            go = 0;
        end
        toff = toff + step
    end
    
    toffs{i} = temptoff;
    T{i} = tempT;
    
end





